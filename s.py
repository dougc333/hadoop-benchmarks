#!/usr/bin/python


import pxssh
import getpass
import string

try:
  s = pxssh.pxssh()
  hostname='r2491-d5-us01'
  hosts=['r2491-d5-us01','r2491-d5-us02','r2491-d5-us03','r2491-d5-us04','r2491-d5-us05','r2491-d5-us06']
  username='doug'
  password='H0onglam'
  #s.login(hostname,username,password)
  #s.sendline('rpm -qa | grep cloudera')
  #s.prompt()
  #res=s.before
  #print("res:"+res)
  #rep=string.replace(res,"rpm -qa | grep cloudera","")
  #print("len:%d"%(len(res)))
  #print("rep:%s"%rep)
  #print("len rep:%d"%len(rep))
  
  for h in hosts: 
    print("h:%s",h)  

except pxssh.ExceptionPxssh as e:
  print("bad")
  print(e)



