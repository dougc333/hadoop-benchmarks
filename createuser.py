#!/usr/bin/python


from pexpect import pxssh

try:
  s = pxssh.pxssh()
  hostname='r2371-d5-us01'
  username='root'
  password='888avb888'
  s.login(hostname,username,password)
  s.sendline('adduser test')
  s.prompt()
  print(s.before)
except pxssh.ExceptionPxssh as e:
  print("bad")
  print(e)

