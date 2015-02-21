#!/usr/bin/expect -f

spawn ssh root@r2442-d5-us02
expect "root@r2442-d5-us02's password:"
send "888avb888\r"
send "sysctl -w vm.swappiness=0\r" 
expect "vm.swappiness = 0"
exit





