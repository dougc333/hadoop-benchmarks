#!/bin/bash

if [ -e /home/doug/hadoop-benchmarks/hostservers ];then
   rm ~/hadoop-benchmarks/hostservers
fi

outputfile=~/hadoop-benchmarks/hostservers

while true; do
    read -p "enter in the host name ie r2391:" hostname
    read -p "enter number of clients:" numclients
    for i in `seq 1 $numclients`;
    do 
      if [ $i -lt 10  ];then
       echo "$hostname-d5-0$i" >> $outputfile
      else
       echo "$hostname-d5-$i" >> $outputfile
      fi
    done 
    exit;
done
