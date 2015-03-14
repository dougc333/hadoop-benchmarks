#!/bin/python



import sys
import os
import re
import optparse
import time
import getpass
import readline
import atexit
try:
    import pexpect
    import pxssh
except ImportError:
    sys.stderr.write("You do not have 'pexpect' installed.\n")
    sys.stderr.write("On Ubuntu you need the 'python-pexpect' package.\n")
    sys.stderr.write("    aptitude -y install python-pexpect\n")
    exit(1)


try:
    raw_input
except NameError:
    raw_input = input

def testhosts():
  for i in range (1,10):
    print i



def main():
  testhosts()
  sys.exit()  
#  s=pxssh.pxssh()
  username='root'
  passwd='888avb888'
  hosts=['r2391-d5-us01','r2491-d5-us02']
  for h in hosts:
    print h
    s=pxssh.pxssh()
    s.login(h,username,passwd)
    s.sendline('lvdisplay  /dev/vg_ks/lv_root')
    s.prompt()
    res=s.before
    print(res)
    print('--------------------')
    print('--------------------')

if __name__ == '__main__':
   main()

