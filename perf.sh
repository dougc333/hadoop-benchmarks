#!/bin/bash -p

LOGFILE=/home/doug/hadoop-benchmarks/logs/test.log

function initlog {
  if [ -a /home/doug/hadoop-benchmarks ]; then
    git clone https://github.com/dougc333/hadoop-benchmarks
  fi
  mkdir /home/doug/hadoop-benchmarks/logs
  touch /home/doug/hadoop-benchmarks/logs/test.log
 
}

function copyperftoremote {
  res=$( cp perf.sh $1:/home/doug/perf.sh)
  echo $res
}


#do I get the mounted directories in a ssh via ansible? Assume no
function testjava {
  if [ -a /usr/java/latest ] ;then
    echo "/usr/java/latest found"
  else 
    echo "/usr/java/latest not found"
  fi
}

#assume ansible copied rpm over
function installjava { 
  sudo wget https://s3-us-west-2.amazonaws.com/dssd/jdk-7u71-linux-x64.rpm
  sudo rpm -ihv jdk-7u71-linux-x64.rpm
  if [ -a /usr/java/latest ];then
    echo "java successfully installed"
  fi
}

#better to put functionality in bash vs. ansible
function testsudo {
  #res=$(sudo cat /etc/sudoers | grep $USER 2>&1)
  res=$(sudo cat /etc/sudoers 2>&1)
  test="$USER is not in the sudoers file."
  echo "res:$res"
  echo "test:$test"
  if [[ "$res" = "$test"* ]] ;then
    echo "user $USER not in sudoers file"
  else
    echo "sudoers file ok"
  fi 
}

#
#addus $USER to sudoers file
function addsudo {
  sudo cp /etc/sudoers /etc/sudoers.orig
  sudo sed '/root[[:space:]]*ALL/a  $USER\tALL=(ALL)\tALL' /etc/sudoers
}

function checkcm {  
  res=$(/opt/dssd/bin/flood ls 2>&1)
  if [ $res='volumes' ]; then
   echo "system good"
  else
   echo "cm not returning volumes; bad system"
   echo "make sure dssd service running"
  fi
}

#assumes volume testhdfsvol created in SM; prob should replace with a ffutil create command
#creates /testhdfsvol directory
function createblkdev {
  if [ -a /testhdfsvol ] ;then
    echo "/testhdfsvol exists"
  else
    echo "creating /testhdfsvol for blockdev"
    res=$( sudo mkdir /testhdfsvol 2>&1 )
    res1=$( sudo chown $USER /teshdfsvol 2>&1 )
    res2=$( sudo chgrp users /testhdfsvol 2>&1 )
  fi

  if [ -a /testhdfsvol ];then
    echo "/testhdfs vol successfully created and/or aleady exists"
  else
    echo "/testhdfsvol not created;debug"
  fi

  #test if create needed
  exists=$(/opt/dssd/bin/flood ls -V testhdfsvol)
  echo "exists:$exists"
  if [ $exists="flood: ls: failed to connect: No such file or directory" ];then
    echo "creating flood object for testhdfsvol"
    res=$(/opt/dssd/bin/flood create -V testhdfsvol -t block -F 4096 -l 200G TestObj1 2>&1)
    echo "creating block device:$res"
    arr=( $res )
    if [ $res='' ];then
      echo "create completed"
    else
      echo "create did not complete:$res debug"
    fi
  else
    echo "flood object created for testhdfsvol name:$exists"
  fi
}

#step 4
#2 cases
#1) when the first node has to create the object in flood for a new volume
#2) flood object id already exists, have to create the testhdfsvol dir wo running flood create
# we should add the different device names dssd-000X and dm-X
#3) format and mount; 
function finddm {
  res1=$(/opt/dssd/bin/flood ls -V testhdfsvol -lhi 2>&1)
  echo "res1:$res1"
  arr=( $res1 )
  echo "object id:${arr[4]}"
  #test if dm-uuid-mpath-${arr[4]} exists under /dev/disk/by-id
  echo "looking for /dev/disk/by-id/dm-uuid-mpath-${arr[4]}"
  if [ -e /dev/disk/by-id/dm-uuid-mpath-${arr[4]} ];then
    echo "found multipath diskid for testhdfsvol" 
  else
    echo "multipath diskid not found"
  fi

  #format
  echo "formatting using multipath id" 
  res=$(sudo mkfs.ext4 /dev/disk/by-id/dm-uuid-mpath-${arr[4]})
  echo $res
  #mount
  echo "mounting"
  res=$(sudo mount /dev/disk/by-id/dm-uuid-mpath-${arr[4]} /testhdfsvol)
  echo $res
  #where do we chmod and chgrp for /testhdfsvol? 
}


#step 2
#funny need to put multipath.conf under /etc not under /etc/multipath
function verifymultipath {
  if [ -a /etc/multipath.conf ]; then
    echo "multipath conf present"
  else
    echo "multipath.conf not present"
    if [ -a /etc/yum.repos.d ] ;then
     echo "centos"
     res=$( sudo cp /opt/dssd/share/example/dm-multipath/multipath.conf.el6.dssd_template /etc/multipath.conf)
    elif [ -a /etc/zypp ];then
     echo "sles"
     res=$( sudo /opt/dssd/share/example/dm-multipath/multipath.conf.sles11sp3.dssd_template /etc/multipath.conf)
    fi
  fi

  #
  res=$(sudo service multipathd status)  
  arr=( $res )
  if [ ${arr[2]}='stopped' ];then
    echo "multipath stoppped"
    #verify multipathfile there and start service
    if [ -a /etc/multipath/multipath.conf ];then 
      res1=$(sudo service multipathd start 2>&1)
      echo "res1: $res1"
      arr1=( $res1 )
      if [ ${arr1[4]}='OK' ];then
        echo "multipathd started"
      else
        echo "multipathd not started debug time"
      fi
    else
      echo "multipath conf file does not exist, debug time"
    fi
  fi
}

#step 3b
#edit /etc/sysconfig/blkdev file and start blkdev service
function startblkdriver { 
  numlines=$(service dssd status | wc -l)
  echo "numlines:$numlines"
  if [ numlines=3 ];then
    echo "dssd running"
  else
    echo "dssd not running"
    turnon=$(sudo service dssd start)
    echo $turnon
  fi
  
  res=$(service dssd-blkdev status)
  arr=( $res )
  echo "startblkdriver res:$res"
  if [ ${arr[4]}="OK"];then
    echo "blkdev service started"
  else
    echo "blkdev service not started"
    res=$(sudo service dssd-blkdev start)
    echo $res
  fi 
}

#step3a
function configblkfile {
  if [ -a /home/dc/tmpfile ]; then
    rm -rf /home/dc/tmpfile
  fi
  sudo chmod 666 /etc/sysconfig/dssd-blkdev
  sudo cp /etc/sysconfig/dssd-blkdev /etc/sysconfig/dssd-blkdevorig
  cd
  output=$(pwd)
  echo "pwd:$output"
  mkdir tmpdir
  cp /etc/sysconfig/dssd-blkdev /home/$USER/tmpdir/
  sed -i -e 's/DSSD_BLKDEV_VOLUME_NAME=\"\"/DSSD_BLKDEV_VOLUME_NAME=\"\testhdfsvol\"/g' tmpdir/dssd-blkdev
  sed -i -e 's/DSSD_BLKDEV_LOGFILE_NAME=\"\"/DSSD_BLKDEV_LOGFILE_NAME=\"\/var\/log\/blkdev.log\"/g' tmpdir/dssd-blkdev
  sudo mv /etc/sysconfig/dssd-blkdev /etc/sysconfig/dssd-blkdevold
  sudo cp tmpdir/dssd-blkdev /etc/sysconfig/dssd-blkdev
}


#restore system back to original state 
#replace dssd-blkdev with original
#remove hadoop from system
#clean up /var/log; /var/lib or /testhdfsvol/log; testhdfsvol/lib
function restore {
  if [ -a /etc/sudoers.orig ];then
    echo "restoring sudoers"
    sudo mv /etc/sudoers.orig /etc/sudoers
  fi

  if [ -a /etc/sysconfig/dssd-blkdevorig ];then
    echo  "restoring blkdev file"
    sudo mv /etc/sysconfig/dssd-blkdevorig /etc/sysconfig/dssd-blkdev
    sudo chmod 644 /etc/sysconfig/dssd-blkdev
    sudo rm /etc/sysconfig/dssd-blkdevold
    if [ -a tmpdir ];then
      rm -rf tmpdir
    fi 
  fi

  sudo mv tmpsite/hdfs-site.xmlorig /usr/lib/hadoop/etc/hadoop/hdfs-site.xml
  sudo mv tmpsite/yarn-site.xmlorig /usr/lib/hadoop/etc/hadoop/yarn-site.xml
  sudo mv tmpsite/mapred-site.xmlorig /usr/lib/hadoop/etc/hadoop/mapred-site.xml
  #sudo rmdir tmpsite
  sudo mv tmpdaemon/hadoop-daemon.shorig /usr/lib/hadoop/sbin/hadoop-daemon.sh
  sudo mv tmpdaemon/yarn-daemon.shorig /usr/lib/hadoop-yarn/sbin/yarn-daemon.sh
  #tbd add the mr-jobhistory-server
}





function clean {
  sudo rm -rf /var/lib/hadoop-hdfs
  sudo rm -rf /var/log/hadoop-hdfs
  sudo rm -rf /var/lib/hadoop-mapreduce
  sudo rm -rf /var/log/hadoop-mapreduce
  sudo rm -rf /var/lib/hadoop-yarn
  sudo rm -rf /var/log/hadoop-yarn
}

function installhadoop {
  sudo wget -O /etc/yum.repos.d/bigtop.repo http://archive.apache.org/dist/bigtop/bigtop-0.8.0/repos/centos6/bigtop.repo
  sudo yum -y install hadoop\*
}


function initnamenode {
  sudo /etc/init.d/hadoop-hdfs-namenode init
}

function starthadoop {
  for i in hadoop-hdfs-namenode hadoop-hdfs-datanode ; 
   do sudo service $i start ; 
  done

  sudo /usr/lib/hadoop/libexec/init-hdfs.sh
  sudo service hadoop-yarn-resourcemanager start
  sudo service hadoop-yarn-nodemanager start
}

#capuure stdout/std err
function runtests {
  $(time hadoop fs -ls -R / > outputfsls)
  time sudo hadoop jar /usr/lib/hadoop-mapreduce/hadoop-mapreduce-examples-2.4.1.jar pi 10 1000 > outputpi
  #
  #time sudo hadoop jar /usr/lib/hadoop-mapreduce/hadoop-mapreduce-client-jobclient-2.4.1.jar TestDFSIO -write -nrFiles 16 -fileSize 250MB -resFile /tmp/TestDFSIOwrite.txt
  #time sudo hadoop jar /usr/lib/hadoop-mapreduce/hadoop-mapreduce-client-jobclient-2.4.1.jar TestDFSIO -read -nrFiles 64 -fileSize 1GB -resFile /tmp/TestDFSIOwrite.txt
  time sudo hadoop jar /usr/lib/hadoop-mapreduce/hadoop-mapreduce-client-jobclient-2.4.1.jar TestDFSIO -write -nrFiles 4 -fileSize 16GB -resFile /tmp/TestDFSIOwrite2.txt
  time sudo hadoop jar /usr/lib/hadoop-mapreduce/hadoop-mapreduce-client-jobclient-2.4.1.jar TestDFSIO -read -nrFiles 4 -fileSize 16GB -resFile /tmp/TestDFSIOread2.txt
  # add all the hadoop tests here....
  
}

#add parsing of OK to verify all services stopped? not necessary
function stophadoop {
  sudo service hadoop-hdfs-datanode stop
  sudo service hadoop-hdfs-namenode stop
  sudo service hadoop-yarn-resourcemanager stop
  sudo service hadoop-yarn-nodemanager stop
}


#this creates a separate set of /var/log and /var/lib dirs under
#/var/perf and /testhdfsvol. replace DIR wirh ARG1; have to install and starthadoop first so users hdfs and yarn exist
function createhadoopdirs {
  sudo mkdir -p $1/lib
  sudo chown hdfs $1/lib
  sudo chgrp hdfs $1/lib
  sudo mkdir -p $1/log
  sudo chown yarn $1/log
  sudo chgrp yarn $1/log
  sudo mkdir -p $1/lib/hadoop-hdfs
  sudo mkdir -p $1/lib/hadoop-httpfs
  sudo mkdir -p $1/lib/hadoop-mapreduce
  sudo mkdir -p $1/lib/hadoop-yarn
  sudo mkdir -p $1/log/hadoop-hdfs
  sudo mkdir -p $1/log/hadoop-httpfs
  sudo mkdir -p $1/log/hadoop-mapreduce
  sudo mkdir -p $1/log/hadoop-yarn
  sudo chown hdfs $1/lib/hadoop-hdfs
  sudo chgrp hadoop $1/lib/hadoop-hdfs
  sudo chown httpfs $1/lib/hadoop-httpfs
  sudo chgrp httpfs $1/lib/hadoop-httpfs
  sudo chown mapred $1/lib/hadoop-mapreduce
  sudo chgrp hadoop $1/lib/hadoop-mapreduce
  sudo chown yarn $1/lib/hadoop-yarn
  sudo chgrp hadoop $1/lib/hadoop-yarn
  sudo chown hdfs $1/log/hadoop-hdfs
  sudo chgrp hadoop $1/log/hadoop-hdfs
  sudo chown httpfs $1/log/hadoop-httpfs
  sudo chgrp httpfs $1/log/hadoop-httpfs
  sudo chown mapred $1/log/hadoop-mapreduce
  sudo chgrp hadoop $1/log/hadoop-mapreduce
  sudo chown yarn $1/log/hadoop-yarn
  sudo chgrp hadoop $1/log/hadoop-yarn
}

#modify hadoop daemons, can prob set from hadoop-env.sh; test
#set $1 to /testhdfsvol or /var/perf/ 
function modworkingdir {
  #modify working directory in hadooop-hdfs-namenode, hadoop-hdfs-datanode, hadoop-hdfs-resourcemanager, hadoop-hdfs-nodemanager
  cp /etc/init.d/hadoop-hdfs-namenode savemenn
  sudo sed 's/WORKING_DIR\=\"\"/WORKING_DIR=\"$1\/lib\/hadoop-hdfs\"/' savemenn > savemenn_fixed
  sudo cp savemenn_fixed /etc/init.d/hadoop-hdfs-namenode

  cp /etc/init.d/hadoop-hdfs-datanode savemedn
  sed 's/WORKING_DIR\=\"\~\/\"/WORKING_DIR=\"$1\/lib\/hadoop-hdfs\"/' savemedn > savemedn_fixed
  sudo cp savemedn_fixed /etc/init.d/hadoop-hdfs-datanode

  cp /etc/init.d/hadoop-yarn-resourcemanager savemerm
  sed 's/WORKING_DIR\=\"\~\/\"/WORKING_DIR=\"$1\/lib\/hadoop-yarn\"/' savemerm > savemerm_fixed
  sudo cp savemerm_fixed /etc/init.d/hadoop-yarn-resourcemanager

  cp /etc/init.d/hadoop-yarn-nodemanager savemenm
  sed 's/WORKING_DIR\=\"\~\/\"/WORKING_DIR=\"$1\/lib\/hadoop-yarn\"/' savemenm > savemenm_fixed
  sudo cp savemenm_fixed /etc/init.d/hadoop-yarn-nodemanager
  # rm saveme*
}

#modify hadoop-env.sh,yarn-env.sh, mapred-env.sh for XX_LOG_DIR
function modenv {
  cd
  if [ -a tmpenv ];then
    rm -rf tmpenv
  fi
  mkdir tmpenv
  chmod 777 tmpenv
  sudo chmod 644 /usr/lib/hadoop/etc/hadoop/hadoop-env.sh
  sudo chmod 644 /usr/lib/hadoop/etc/hadoop/yarn-env.sh
  sudo chmod 644 /usr/lib/hadoop/etc/hadoop/mapred-env.sh
  sudo cp /usr/lib/hadoop/etc/hadoop/hadoop-env.sh tmpenv/hadoop-env.shorig
  cp tmpenv/hadoop-env.shorig tmpenv/hadoop-env.sh
  awk -v n=20 -v s="export HADOOP_LOG_DIR=$1" 'NR == n {print s} {print}' tmpenv/hadoop-env.sh 
#  sudo cp /usr/lib/hadoop/etc/hadoop/yarn-env.sh tmpenv/yarn-env.shorig
#  cp tmpenv/yarn-env.shorig tmpenv/yarn-env.sh
#  awk -v n=21 -v s="export YARN_LOG_DIR=$1" 'NR == n {print s} {print}' tmpenv/yarn-env.sh
#  sudo cp tmpenv/hadoop-env.sh /usr/lib/hadoop/etc/hadoop/hadoop-env.sh 
#  sudo cp /usr/lib/hadoop/etc/hadoop/mapred-env.sh tmpenv/mapred-env.shorig
#  cp tmpenv/mapred-env.shorig tmpenv/mapred-env.sh
#  sudo awk -v n=21 -v s="export HADOOP_MAPRED_LOG_DIR=$1" 'NR == n {print s} {print}' tmpenv/mapred-env.sh
  
#  sudo chown root tmpenv/hadoop-env.sh
#  sudo chgrp root tmpenv/hadoop-env.sh
#  sudo chown root tmpenv/mapred-env.sh
#  sudo chgrp root tmpenv/mapred-env.sh
#  sudo chown root tmpenv/yarn-env.sh
#  sudo chgrp root tmpenv/yarn-env.sh

#  sudo mv tmpenv/mapred-env.sh /usr/lib/hadoop/etc/hadoop/mapred-env.sh
  
}

#we cant move this into the hadoop-env.sh, yarn-env.sh, mapred-env.sh file instead?
#is the same amount of work; more clear 
function moddaemon {
  modhadoopdaemon
  modyarndaemon
  
}


#modify the yarn and hdfs daemons $HADOOP_LOG_DIR
#insert at line 41, $1=/testhdfsvol/log/hadoop-hdfs or /var/perf/log/hadoop-hdfs
function modhadopdaemon {
  sudo cp /usr/lib/hadoop/sbin/hadoop-daemon.sh tmpdaemon/hadoop-daemon.shorig 
  awk -v n=41 -v s="export HADOOP_LOG_DIR=$1" 'NR == n {print s} {print}' tmpdaemon/hadoop-daemon.shorig > tmpdaemon/hadoop-daemon.sh 
  sudo mv tmpdaemon/hadoop-daemon.sh /usr/lib/hadoop/sbin/hadoop-daemon.sh
}

#$1 is either /testhdfsvol/log/hadoop-yarn or /var/perf/log/hadoop-yarn
# test if line exists before insert
function modyarndaemon {
  sudo cp /usr/lib/hadoop-yarn/sbin/yarn-daemon tmpdaemon/yarn-daemon.shorig
  awk -v n=41 -v s="YARN_LOG_DIR=$1" 'NR == n {print s} {print}' /usr/lib/hadoop-yarn/sbin/yarn-daemon.shorig > tmpdaemon/yarn-daemon.sh
  sudo mv tmpdaemon/yarn-daemon.sh /usr/lib/hadoop-yarn/sbin/yarn-daemon.sh
}
#add mrjobshistorydaemon


#modify hdfs-site.xml,yarn-site.xml, mapred-site.xml
#$1 is /testhdfsvol for blockdev or /var/perf for local
function modsitefiles {
  mkdir tmpsite
  sudo cp /etc/hadoop/conf/hdfs-site.xml tmpsite/hdfs-site.xmlorig
  sed 's/var/$1/g' hdfs-site.xmlorig > /etc/hadoop/conf/hdfs-site.xml
  sudo cp /etc/hadoop/conf/mapred-site.xml tmpsite/mapred-site.xmlorig
  sudo sed 's/var/$1/g' mapred-site.xmlorig > /etc/hadoop/conf/mapred-site.xml
  sudo cp /etc/hadoop/conf/yarn-site.xml tmpsite/yarn-site.xmlorig
  sed 's/var/$1/g' yarn-site.xmlorig > /etc/hadoop/conf/yarn-site.xml
}
 
$@
