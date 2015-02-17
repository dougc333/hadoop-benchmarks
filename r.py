#!/usr/bin/python


import pxssh
import getpass


try:
  s = pxssh.pxssh()
  hostname='r2371-d5-sm0'
  username='admin'
  password='admin'
  s.login(hostname,username,password)
  s.sendline('\t')
  s.prompt()
  print(s.before)  
#  s.sendline('cd hadoop-benchmarks')
#  s.prompt()
#  print(s.before)
#  s.sendline('bash perf.sh runtests')
#  s.prompt()
# print(s.before)
except pxssh.ExceptionPxssh as e:
  print("bad")
  print(e)

