#!/usr/bin/python


import pxssh
import getpass


try:
  s = pxssh.pxssh()
  hostname='r2391-d5-us01'
  username='doug'
  password='H0onglam'
  s.login(hostname,username,password)
  s.sendline('ls -l /home/doug/hadoop-benchmarks')
  s.prompt()
  print(s.before)  
  s.sendline('cd hadoop-benchmarks')
  s.prompt()
  print(s.before)
  s.sendline('bash perf.sh runtests')
  s.prompt()
  print(s.before)
except pxssh.ExceptionPxssh as e:
  print("bad")
  print(e)
