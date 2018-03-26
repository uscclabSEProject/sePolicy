#!/bin/bash
if [ `id -u` != "0" ] ; then
        echo "Please run with sudo right."
	exit 1
fi
echo "Install NCsudo module."
make -f /usr/share/selinux/devel/Makefile sePolicy/NCsudo/NCsudo.pp
semodule -i sePolicy/NCsudo/NCsudo.pp
echo "Install NCnetwork module. If you want to change setting please look up final report."
make -f /usr/share/selinux/devel/Makefile sePolicy/NCnetwork/NCnetwork.pp
semodule -i sePolicy/NCnetwork/NCnetwork.pp