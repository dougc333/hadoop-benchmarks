#!/usr/bin/python


import pxssh
import getpass


try:
  s = pxssh.pxssh()
  hostname='r2391-d5-us01'
  username='doug'
  password='H0onglam'
  s.login(hostname,username,password)
  s.sendline('ls')
  s.prompt()
  print(s.before)  
except pxssh.ExceptionPxssh as e:
  print("bad")
  print(e)

