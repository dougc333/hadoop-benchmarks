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
  s.sendline('cd /home/doug/hadoop-benchmarks/')
  s.sendline('bash perf.sh testjava')
  s.prompt()
  print(s.before)
  s.sendline('sudo rpm -ivh /home/doug/hadoop-benchmarks/jdk-7u71-linux-x64.rpm')
  s.prompt()
  print(s.before)
except pxssh.ExceptionPxssh as e:
  print("bad")
  print(e)

