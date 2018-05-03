semanage fcontext -d -t NCnoexec_t "/home/NCSISTuser/Downloads(/.*)?"
semodule -r NCnoexec
chcon -R NCSISTuser_u:object_r:user_home_t:s0 /home/NCSISTuser/Downloads
