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
		time=`ls -l --time-style="+%x %X" NCnoexec.te | awk '{ printf "%s %s", $6, $7 }'`
		rules=`ausearch --start $time -m avc --raw -se NCnoexec`
		if [ x"$rules" != "x" ] ; then
			echo "Found avc's to update policy with"
			echo -e "$rules" | audit2allow -R
			echo "Do you want these changes added to policy [y/n]?"
			read ANS
			if [ "$ANS" = "y" -o "$ANS" = "Y" ] ; then
				echo "Updating policy"
				echo -e "$rules" | audit2allow -R >> NCnoexec.te
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
make -f /usr/share/selinux/devel/Makefile NCnoexec.pp || exit
/usr/sbin/semodule -i NCnoexec.pp



# Set the file context on /home/NCSISTuser/Downloads
semanage fcontext -a -t NCnoexec_t "/home/NCSISTuser/Downloads(/.*)?"

# Fixing the file context on /home/NCSISTuser/Downloads
/sbin/restorecon -Rv /home/NCSISTuser/Downloads

# Fixing the file context on /tmp/mozilla_NCSISTuser0
/sbin/restorecon -Rv /tmp/mozilla_NCSISTuser0



