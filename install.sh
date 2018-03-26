#!/bin/sh

# Please use sudo to execute this script unless you are root.
if [ `id -u` != "0" ] ; then
        echo "Please run with sudo right."
	exit 1
fi


# change excute permission of shellscripts below
chmod +100 sePolicy/NCSISTuser/NCSISTuser.sh
chmod +100 sePolicy/NCSISTprog/NCSISTprog.sh
chmod +100 sePolicy/NCnoexec/NCnoexec.sh

# create Linux user NCSISTuser
echo "Create an linux user NCSISTuser"
useradd NCSISTuser 
( echo "uscc"
  echo "uscc" ) | passwd NCSISTuser  

# install NCSISTuser module : create SElinux label => NCSISTuser_u:NCSISTuser_r:NCSISTuser_t
./sePolicy/NCSISTuser/NCSISTuser.sh

# bind SElinux user and Linux user
semanage login -a -s NCSISTuser_u NCSISTuser

# move programs and files to assigned directory 
mkdir /home/NCSISTuser/program
chcon -u NCSISTuser_u /home/NCSISTuser/program
cp -r seProgram /home/NCSISTuser/program
chown -R NCSISTuser:NCSISTuser /home/NCSISTuser/program

# install NCSISTprog module
./sePolicy/NCSISTprog/NCSISTprog.sh


# compile and install NCSISTprogexec module
checkmodule -M -m -o sePolicy/NCSISTprogexec/NCSISTprogexec.mod sePolicy/NCSISTprogexec/NCSISTprogexec.te
semodule_package -o sePolicy/NCSISTprogexec/NCSISTprogexec.pp -m sePolicy/NCSISTprogexec/NCSISTprogexec.mod
semodule -i sePolicy/NCSISTprogexec/NCSISTprogexec.pp

# temporarily open port 9000 for listener to listen pp.py
firewall-cmd --add-port=9000/tcp

# create a directory for NCnoexec module: this is a directory a downloaded file will pass.
mkdir /tmp/mozilla_NCSISTuser0
chmod 700 /tmp/mozilla_NCSISTuser0
chown NCSISTuser:NCSISTuser /tmp/mozilla_NCSISTuser0

# Before login NCSISTuser, Download directoy will not be created.
# So we create it first before install module.
mkdir /home/NCSISTuser/Downloads
chown NCSISTuser:NCSISTuser /home/NCSISTuser/Downloads
chcon -u NCSISTuser_u /home/NCSISTuser/Downloads

# install NCnoexec module
./sePolicy/NCnoexec/NCnoexec.sh

echo "Install NCsudo module."
make -f /usr/share/selinux/devel/Makefile sePolicy/NCsudo/NCsudo.pp
semodule -i sePolicy/NCsudo/NCsudo.pp
echo "Install NCnetwork module. If you want to change setting please look up final report."
make -f /usr/share/selinux/devel/Makefile sePolicy/NCnetwork/NCnetwork.pp
semodule -i sePolicy/NCnetwork/NCnetwork.pp
