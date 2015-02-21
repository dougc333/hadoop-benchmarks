#!/bin/bash -p

function foo {
echo "foo"
for i in $(seq 1 $1);
do
  echo $i
  if [ $i -le 5 ];then
    echo "smaller equal than 5"
  fi
done
}

function a {
  for i in $(seq -f%02g 1 $1); 
  do
    echo $i
  done
}

$@

