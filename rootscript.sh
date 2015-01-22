#!/bin/bash -p

function addsudouser {
  cd /home/$USER
  git clone https://github.com/dougc333/hadoop-benchmarks
  cd hadoop-benchmarks
  res=$(scp sudoers.fix root@$1:/etc/sudoers)
  echo $res
}

function restore {
  res=$(scp sudoers.backup root@$1:/etc/sudoers)
}



