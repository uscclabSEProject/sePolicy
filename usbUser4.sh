#!/bin/sh -e

DIRNAME=`dirname $0`
cd $DIRNAME
USAGE="$0 [ --update ]"
if [ `id -u` != 0 ]; then
echo 'You must be root to run this script'
exit 1
fi

if [ $# -eq 1 ]; then
	if [ "$1" = "--update" ] ; then
		time=`ls -l --time-style="+%x %X" usbUser4.te | awk '{ printf "%s %s", $6, $7 }'`
		rules=`ausearch --start $time -m avc --raw -se usbUser4`
		if [ x"$rules" != "x" ] ; then
			echo "Found avc's to update policy with"
			echo -e "$rules" | audit2allow -R
			echo "Do you want these changes added to policy [y/n]?"
			read ANS
			if [ "$ANS" = "y" -o "$ANS" = "Y" ] ; then
				echo "Updating policy"
				echo -e "$rules" | audit2allow -R >> usbUser4.te
				# Fall though and rebuild policy
			else
				exit 0
			fi
		else
			echo "No new avcs found"
			exit 0
		fi
	else
		echo -e $USAGE
		exit 1
	fi
elif [ $# -ge 2 ] ; then
	echo -e $USAGE
	exit 1
fi

echo "Building and Loading Policy"
set -x
make -f /usr/share/selinux/devel/Makefile usbUser4.pp || exit
/usr/sbin/semodule -i usbUser4.pp

# Generate a man page off the installed module
sepolicy manpage -p . -d usbUser4_t
# Adding SELinux user usbUser4_u
/usr/sbin/semanage user -a -R "usbUser4_r" usbUser4_u

cat > usbUser4_u << _EOF
usbUser4_r:usbUser4_t	usbUser4_r:usbUser4_t
system_r:crond_t		usbUser4_r:usbUser4_t
system_r:initrc_su_t		usbUser4_r:usbUser4_t
system_r:local_login_t		usbUser4_r:usbUser4_t
system_r:remote_login_t		usbUser4_r:usbUser4_t
system_r:sshd_t				usbUser4_r:usbUser4_t
system_r:xdm_t				usbUser4_r:usbUser4_t
_EOF
if [ ! -f /etc/selinux/targeted/contexts/users/usbUser4_u ]; then
   cp usbUser4_u /etc/selinux/targeted/contexts/users/
fi
# Generate a rpm package for the newly generated policy

pwd=$(pwd)
rpmbuild --define "_sourcedir ${pwd}" --define "_specdir ${pwd}" --define "_builddir ${pwd}" --define "_srcrpmdir ${pwd}" --define "_rpmdir ${pwd}" --define "_buildrootdir ${pwd}/.build"  -ba usbUser4_selinux.spec
