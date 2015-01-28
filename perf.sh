#!/bin/bash -p

#remove interactive mode; run batch mode; 
#remove jdk; use open jdk install instead to match all nodes
LOGFILE=/home/doug/hadoop-benchmarks/logs/test.log

function initlog {
# too slow, makes me wait5 secs
#  rm -rf /home/doug/hadoop-benchmarks
#  git clone https://github.com/dougc333/hadoop-benchmarks
  if [ -e /home/doug/hadoop-benchmarks/logs ];then
    rm $LOGFILE
    touch $LOGFILE
    echo "logfile cleared" >> $LOGFILE
  else
    mkdir /home/doug/hadoop-benchmarks/logs
    touch $LOGFILE
    echo "logfile created" >> $LOGFILE 
  fi
}

#Usage: $1=host name
function addsshkey {
  cat ~/.ssh/id_rsa.pub | ssh doug@$1 'cat >> .ssh/authorized_keys'
}

#Usage: $1=host name
function addsudoer {
  scp sudoers.fix root@$1:/etc/sudoers
}


#do I get the mounted directories in a ssh via ansible? Assume no
function testoraclejava {
  testsudo
  if [ -e /usr/java/latest ] ;then
    echo "/usr/java/latest found" >> $LOGFILE
  else   
    echo "/usr/java/latest not found" >> $LOGFILE
    installjava
  fi
}

#assume ansible copied rpm over
function installjava { 
  echo "installjava" >> $LOGFILE
  cd /home/doug
  if [ -e jdk-7u71-linux-x64.rpm ];then
    echo "jdk downloaded" >> $LOGFILE
  else
    echo "downloading jdk" >> $LOGFILE  
    res=$(wget https://s3-us-west-2.amazonaws.com/dssd/jdk-7u71-linux-x64.rpm --no-check-certificate 2>&1)
    echo $res >> $LOGFILE
  fi

  echo "starting rpm install" >> $LOGFILE
 
  sudo rpm -ihv jdk-7u71-linux-x64.rpm 
  echo "end rpm install" >> $LOGFILE
  export JAVA_HOME=/usr/java/jdk1.7.0_71/
  export PATH=$PATH:$JAVA_HOME/bin
  
  if [ -e /usr/java/latest ];then
    echo "java successfully installed">>$LOGFILE
  else 
    echo "no java" >> $LOGFILE
  fi
}


#not used for now.. install oracle jdk for hadoop; is easier to use openjdk1.7
#bc this is in the centos repos 
function installopenjdk {
  sudo yum install java-1.87.0-openjdk
}


#better to put functionality in bash vs. ansible
function testsudo {
  echo "testsudo" >> $LOGFILE
  #res=$(sudo cat /etc/sudoers | grep $USER 2>&1)
  res=$(sudo cat /etc/sudoers 2>&1)
  test="$USER is not in the sudoers file." 
  echo "res:$res"
  echo "test:$test"
  if [[ "$res" = "$test"* ]] ;then
    echo "user $USER not in sudoers file" >> $LOGFILE
  else
    echo "sudoers file ok" >> $LOGFILE
  fi 
}

#
#addus $USER to sudoers file; 
function addsudo {
  #modify to scp command? modify to where this is run outside of maven
  cd #assume in hadoop-benchmarks
  sudo scp root@/$1:/etc/sudoers sudoers.orig
  cp sudoers.orig sudoers.fixtest
  #sudo sed '/root[[:space:]]*ALL/a  $USER\tALL=(ALL)\tALL' sudoers.fixtest
  #verify this works. Right now we have put sudoers.fix w/hardcoded user in hadoop-benchmarks
}

function checkcm {  
  res=$(/opt/dssd/bin/flood ls 2>&1)
  if [ $res='volumes' ]; then
   echo "system good" >> $LOGFILE
  else
   echo "cm not returning volumes; bad system" >>$LOGFILE
   echo "make sure dssd service running" >>$LOGFILE
  fi
}

#assumes volume testhdfsvol created in SM; prob should replace with a ffutil create command
#creates /testhdfsvol directory
function createblkdev {
  echo "function createblkdev" >> $LOGFILE
  if [ -e /testhdfsvol ] ;then
    echo "/testhdfsvol exists" >> $LOGFILE
  else
    echo "creating /testhdfsvol for blockdev"
    res=$( sudo mkdir /testhdfsvol 2>&1 )
    res1=$( sudo chown $USER /teshdfsvol 2>&1 )
    res2=$( sudo chgrp users /testhdfsvol 2>&1 )
  fi

  if [ -e /testhdfsvol ];then
    echo "/testhdfs vol successfully created and/or aleady exists" >> $LOGFILE
  else
    echo "/testhdfsvol not created;debug" >> $LOGFILE
  fi

  #test if create needed
  exists=$(/opt/dssd/bin/flood ls -V testhdfsvol)
  echo "exists:$exists" >> $LOGFILE
  if [ $exists="flood: ls: failed to connect: No such file or directory" ];then
    echo "creating flood object for testhdfsvol"
    res=$(/opt/dssd/bin/flood create -V testhdfsvol -t block -F 4096 -l 200G TestObj1 2>&1)
    echo "creating block device:$res" >> $LOGFILE
    arr=( $res )
    if [ -z "$res" ];then
      echo "create completed" >> $LOGFILE
    else
      echo "create did not complete:$res debug" >> $LOGFILE
    fi
  else
    echo "flood object created for testhdfsvol name:$exists" >> $LOGFILE
  fi
}

#step 4
#2 cases
#1) when the first node has to create the object in flood for a new volume
#2) flood object id already exists, have to create the testhdfsvol dir wo running flood create
# we should add the different device names dssd-000X and dm-X
#3) format and mount; 
function finddm {
  echo "function finddm" >> $LOGFILE
  res1=$(/opt/dssd/bin/flood ls -V testhdfsvol -lhi 2>&1)
  echo "res1:$res1" >> $LOGFILE
  arr=( $res1 )
  echo "object id:${arr[4]}" >> $LOGFILE
  #test if dm-uuid-mpath-${arr[4]} exists under /dev/disk/by-id
  echo "looking for /dev/disk/by-id/dm-uuid-mpath-${arr[4]}" >> $LOGFILE
  if [ -e /dev/disk/by-id/dm-uuid-mpath-${arr[4]} ];then
    echo "found multipath diskid for testhdfsvol"  >> $LOGFILE
  else
    echo "multipath diskid not found" >> $LOGFILE
  fi

  #format
  echo "formatting using multipath id" >> $LOGFILE
  res=$(sudo mkfs.ext4 /dev/disk/by-id/dm-uuid-mpath-${arr[4]})
  echo $res >> $LOGFILE
  #mount
  echo "mounting" >> $LOGFILE
  res=$(sudo mount /dev/disk/by-id/dm-uuid-mpath-${arr[4]} /testhdfsvol)
  echo $res >> $LOGFILE
  #where do we chmod and chgrp for /testhdfsvol? 
}

#step5
function verifytesthdfsvol {
  echo "testhdfsvol function" >> $LOGFILE
  if [ -e /testhdfsvol ];then
    echo "testhdfsvol exists" >> $LOGFILE
    if [ -e /testhdfsvol/lost+found ];then
      echo "testhdfsvol successfully created found lost+found" >> $LOGFILE
      createhadoopdirs /testhdfsvol
    else
      echo "lost+found not found" >> $LOGFILE
    fi
  else
    echo "testhdfsvol does not exist" >> $LOGFILE
  fi 
  
}

#step 2
#funny need to put multipath.conf under /etc not under /etc/multipath
function verifymultipath {
  echo "function verifymultipath" >> $LOGFILE
  if [ -e /etc/multipath.conf ]; then
    echo "multipath conf present" >> $LOGFILE
  else
    echo "multipath.conf not present"
    if [ -e /etc/yum.repos.d ] ;then
     echo "centos copying template file" >> $LOGFILE
     if [ -e /opt/dssd/share/example/dm-multipath/multipath.conf.el6.dssd_template ]; then
       res=$( sudo cp /opt/dssd/share/example/dm-multipath/multipath.conf.el6.dssd_template /etc/multipath.conf)
       echo $res >> $LOGFILE
     else
       echo "centos template file does not exist; debug" >> $LOGFILE
     fi
    elif [ -e /etc/zypp ];then
     echo "sles" >> $LOGFILE
     res=$( sudo /opt/dssd/share/example/dm-multipath/multipath.conf.sles11sp3.dssd_template /etc/multipath.conf)
     echo $res >> $LOGFILE
    fi
  fi
  if [ -e /etc/multipath.conf ];then
   echo "multipath file copied successfully" >> $LOGFILE
  fi
  #
  res=$(sudo service multipathd status)  
  arr=( $res )
  echo "arr:$arr" >> $LOGFILE
  if [ ${arr[2]}='stopped' ];then
    echo "multipath stoppped" >> $LOGFILE
    #verify multipathfile there and start service
    if [ -e /etc/multipath.conf ];then 
      res1=$(sudo service multipathd start 2>&1)
      echo "res1: $res1" >> $LOGFILE
      arr1=( $res1 )
      if [ ${arr1[4]}='OK' ];then
        echo "multipathd started" >> $LOGFILE
      else
        echo "multipathd not started debug time" >> $LOGFILE
      fi
    else
      echo "multipath conf file does not exist, debug time" >> $LOGFILE
    fi
  fi
}

#step 3b
#edit /etc/sysconfig/blkdev file and start blkdev service
function startblkdriver { 
  echo "function startblkdriver" >> $LOGFILE
  numlines=$(service dssd status | wc -l)
  echo "numlines:$numlines" >> $LOGFILE
  if [ numlines=3 ];then
    echo "dssd running" >> $LOGFILE
  else
    echo "dssd not running" >> $LOGFILE
    turnon=$(sudo service dssd start)
    echo $turnon >> $LOGFILE
  fi
  
  res=$(service dssd-blkdev status)
  arr=( $res )
  echo "startblkdriver res:$res" >> $LOGFILE
  if [ ${arr[4]}="OK" ];then
    echo "blkdev service started" >> $LOGFILE
  else
    echo "blkdev service not started" >> $LOGFILE
    res=$(sudo service dssd-blkdev start)
    echo $res >> $LOGFILE
  fi 
}

#step3a
function configblkfile { 
  echo "function configblkfile" >> $LOGFILE
  if [ -e /home/dc/tmpfile ]; then
    rm -rf /home/dc/tmpfile
  fi
  sudo chmod 666 /etc/sysconfig/dssd-blkdev
  sudo cp /etc/sysconfig/dssd-blkdev /etc/sysconfig/dssd-blkdevorig
  cd
  output=$(pwd)
  echo "pwd:$output" >> $LOGFILE
  rm -rf tmpdir
  mkdir tmpdir
  cp /etc/sysconfig/dssd-blkdev /home/$USER/tmpdir/
  sed -i -e 's/DSSD_BLKDEV_VOLUME_NAME=\"\"/DSSD_BLKDEV_VOLUME_NAME=\"testhdfsvol\"/g' tmpdir/dssd-blkdev
  sed -i -e 's/DSSD_BLKDEV_LOGFILE_NAME=\"\"/DSSD_BLKDEV_LOGFILE_NAME=\"\/var\/log\/blkdev.log\"/g' tmpdir/dssd-blkdev
  sudo mv /etc/sysconfig/dssd-blkdev /etc/sysconfig/dssd-blkdevold
  sudo cp tmpdir/dssd-blkdev /etc/sysconfig/dssd-blkdev
}


#restore dssd-blkdev with original
#remove hadoop from system
#removedirs /var/log; /var/lib or /testhdfsvol/log; testhdfsvol/lib
#remove daemons in /etc/init.d
#restore orig sudoers file
function restore {
  if [ -e /etc/sudoers.orig ];then
    echo "restoring sudoers"
    sudo mv /etc/sudoers.orig /etc/sudoers
  fi

  if [ -e /etc/sysconfig/dssd-blkdevorig ];then
    echo  "restoring blkdev file"
    sudo mv /etc/sysconfig/dssd-blkdevorig /etc/sysconfig/dssd-blkdev
    sudo chmod 644 /etc/sysconfig/dssd-blkdev
    sudo rm /etc/sysconfig/dssd-blkdevold
    if [ -e tmpdir ];then
      rm -rf tmpdir
    fi 
  fi

  #sudo mv tmpsite/hdfs-site.xmlorig /usr/lib/hadoop/etc/hadoop/hdfs-site.xml
  #sudo mv tmpsite/yarn-site.xmlorig /usr/lib/hadoop/etc/hadoop/yarn-site.xml
  #sudo mv tmpsite/mapred-site.xmlorig /usr/lib/hadoop/etc/hadoop/mapred-site.xml
  
  sudo mv tmpdaemon/hadoop-daemon.shorig /usr/lib/hadoop/sbin/hadoop-daemon.sh
  sudo mv tmpdaemon/yarn-daemon.shorig /usr/lib/hadoop-yarn/sbin/yarn-daemon.sh
  
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
  echo "function installhadoop" >> $LOGFILE
  res=$(sudo wget -O /etc/yum.repos.d/bigtop.repo http://archive.apache.org/dist/bigtop/bigtop-0.8.0/repos/centos6/bigtop.repo)
  echo "$res" >> $LOGFILE
  res1=$(sudo yum -y install hadoop\*)
  echo "$res1" >> $LOGFILE
}


function initnamenode {
  echo "function initnamenode" >> $LOGFILE
  res=$(sudo /etc/init.d/hadoop-hdfs-namenode init)
  echo "$res" >> $LOGFILE
}

function starthadoop {
  echo "function starthadoop" >> $LOGFILE
  for i in hadoop-hdfs-namenode hadoop-hdfs-datanode ; 
   do sudo service $i start ; 
  done

  res=$(sudo /usr/lib/hadoop/libexec/init-hdfs.sh)
  echo "$res" >> $LOGFILE
  res1=$(sudo service hadoop-yarn-resourcemanager start)
  echo "$res1" >> $LOGFILE
  res2=(sudo service hadoop-yarn-nodemanager start)
  echo "$res2" >> $LOGFILE
}

#capuure stdout/std err
function runtests {
  rm outputfsls
  rm outputpi
  (time hadoop fs -ls -R / > outputfsls)
  time sudo hadoop jar /usr/lib/hadoop-mapreduce/hadoop-mapreduce-examples-2.4.1.jar pi 10 1000 > outputpi
  #
  time sudo hadoop jar /usr/lib/hadoop-mapreduce/hadoop-mapreduce-client-jobclient-2.4.1.jar TestDFSIO -write -nrFiles 64 -fileSize 1GB -resFile /tmp/TestDFSIOwrite64_1G.txt
  time sudo hadoop jar /usr/lib/hadoop-mapreduce/hadoop-mapreduce-client-jobclient-2.4.1.jar TestDFSIO -read -nrFiles 64 -fileSize 1GB -resFile /tmp/TestDFSIOread64_1G.txt
  time sudo hadoop jar /usr/lib/hadoop-mapreduce/hadoop-mapreduce-client-jobclient-2.4.1.jar TestDFSIO -write -nrFiles 4 -fileSize 16GB -resFile /tmp/TestDFSIOwrite4_16G.txt
  time sudo hadoop jar /usr/lib/hadoop-mapreduce/hadoop-mapreduce-client-jobclient-2.4.1.jar TestDFSIO -read -nrFiles 4 -fileSize 16GB -resFile /tmp/TestDFSIOread4_16G.txt
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
  echo "function createhadoopdirs" >> $LOGFILE
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


#for /etc/init.d/hadoop-hdfs-namenode,datanode modifies WORKING_DIR from /var/lib/hadoop-hdfs to /testhdfsvol/lib/hadoop-hdfs
#for /etc/init.d/hadoop-hdfs-nodemanager,resourcemanager modifies WORKING_DIR from /var/lib/hadoop-yarn to /testhdfsvol/lib/hadoop-yarn
#for hadoop-hdfs-zkfc modifles WORKING_DIR from /var/lib/hadoop-hdfs to /testhdfsvol/lib/hadoop-hdfs 
#assumes the /etc/init.d/hadoop-yarn-resourcemanager.orig, /etc/init.d/hadoop-yarn-nodemanager
#/etc/init.d/hadoop-hdfs-namenode, /etc/init.d/hadoop-hdfs-datanode are scp copied to /tmpsvc
function modworkingdir {
# don't automate the copy. Too confusing to user to have multiple versions of files
#  cp /etc/init.d/hadoop-hdfs-namenode tmpsvc/hadoop-hdfs-namenode.orig
   [ ! -f tmpsvc/hadoop-hdfs-namenode.orig ] && sudo cp /etc/init.d/hadoop-hdfs-namenode tmpsvc/hadoop-hdfs-namenode.orig
   [ ! -f tmpsvc/hadoop-hdfs-datanode.orig ] && sudo cp /etc/init.d/hadoop-hdfs-datanode tmpsvc/hadoop-hdfs-datanode.orig
   [ ! -f tmpsvc/hadoop-yarn-nodemanager.orig ] && sudo cp /etc/init.d/hadoop-yarn-nodemanager tmpsvc/hadoop-yarn-nodemanager.orig
   [ ! -f tmpsvc/hadoop-yarn-resourcemanager.orig ] && sudo cp /etc/init.d/hadoop-yarn-resourcemanager tmpsvc/hadoop-yarn-resourcemanager.orig

   cd ~/hadoop-benchmarks/tmpsvc
   for modfile in $( ls *.orig ); do
     echo "modifying WORKING_DIR for $modfile" >> $LOGFILE
     sed 's/^WORKING_DIR.*/WORKING_DIR=\"\/testhdfsvol\/lib\/hadoop-hdfs\"/' $modfile > $modfile.mod
     #sudo cp tmpsvc/savemenn /etc/init.d/hadoop-hdfs-namenode
   done

   for cpfile in $( ls *.mod ); do
     echo "copying to /etc/init.d" >> $LOGFILE
     y=${cpfile%%.*}
     echo "copying $cpfile to /etc/init.d/$y"
     sudo cp $cpfile /etc/init.d/$y
   done

}

#modify hadoop-env.sh,yarn-env.sh, mapred-env.sh for XX_LOG_DIR
#run with bash perf.sh modenv /testhdfsvol for dssd blkdrv 
#or /var for hadoop (should be default if files are restored, should not need to run /var) 
#
function modenv {
  cd
  if [ -d tmpenv ];then
    rm -rf tmpenv
  fi
  mkdir tmpenv
  chmod 777 tmpenv
  sudo chmod 644 /usr/lib/hadoop/etc/hadoop/hadoop-env.sh
  sudo chmod 644 /usr/lib/hadoop/etc/hadoop/yarn-env.sh
  sudo chmod 644 /usr/lib/hadoop/etc/hadoop/mapred-env.sh

  sudo cp /usr/lib/hadoop/etc/hadoop/hadoop-env.sh tmpenv/hadoop-env.shorig  
  awk -v n=20 -v s="export HADOOP_LOG_DIR=$1/log/hadoop-hdfs" 'NR == n {print s} {print}' tmpenv/hadoop-env.shorig > tmpenv/hadoop-env.sh 
  sudo cp tmpenv/hadoop-env.sh /usr/lib/hadoop/etc/hadoop/hadoop-env.sh
  
  sudo cp /usr/lib/hadoop/etc/hadoop/yarn-env.sh tmpenv/yarn-env.shorig
  awk -v n=21 -v s="export YARN_LOG_DIR=$1/log/hadoop-yarn" 'NR == n {print s} {print}' tmpenv/yarn-env.shorig > tmpenv/yarn-env.sh
  sudo cp tmpenv/yarn-env.sh /usr/lib/hadoop/etc/hadoop/yarn-env.sh
  
  sudo cp /usr/lib/hadoop/etc/hadoop/mapred-env.sh tmpenv/mapred-env.shorig
  sudo awk -v n=21 -v s="export HADOOP_MAPRED_LOG_DIR=$1/log/hadoop-mapred" 'NR == n {print s} {print}' tmpenv/mapred-env.shorig > tmpenv/mapred-env.sh
  sudo cp tmpenv/mapred-env.sh /usr/lib/hadoop/etc/hadoop/mapred-env.sh
  
}

#we need to modify daemon files if hadoop-env, yarn-env and mapred-env is changed?????
#modify the yarn and hdfs daemons $HADOOP_LOG_DIR
#insert at line 41, $1=/testhdfsvol/log/hadoop-hdfs or /var/perf/log/hadoop-hdfs
function moddaemon {
  cd
  if [ -e tmpdaemon ];then
   rm -rf tmpdaemon
  fi
  mkdir tmpdaemon
  chmod 0666 /usr/lib/hadoop/sbin/hadoop-daemon.sh
  cp /usr/lib/hadoop/sbin/hadoop-daemon.sh tmpdaemon/hadoop-daemon.shorig 
  awk -v n=41 -v s="export HADOOP_LOG_DIR=$1/log/hadoop-hdfs" 'NR == n {print s} {print}' tmpdaemon/hadoop-daemon.shorig > tmpdaemon/hadoop-daemon.sh 
  sudo cp tmpdaemon/hadoop-daemon.sh /usr/lib/hadoop/sbin/hadoop-daemon.sh
  chmod 0755 /usr/lib/hadoop/sbin/hadoop-daemon.sh
  sudo chown root /usr/lib/hadoop/sbin/hadoop-daemon.sh
  sudo chgrp root /usr/lib/hadoop/sbin/hadoop-daemon.sh

  chmod 0666 /usr/lib/hadoop-yarn/sbin/yarn-daemon.sh
  sudo cp /usr/lib/hadoop-yarn/sbin/yarn-daemon.sh tmpdaemon/yarn-daemon.shorig
  awk -v n=41 -v s="YARN_LOG_DIR=$1/log/hadoop-yarn" 'NR == n {print s} {print}' tmpdaemon/yarn-daemon.shorig > tmpdaemon/yarn-daemon.sh
  sudo cp tmpdaemon/yarn-daemon.sh /usr/lib/hadoop-yarn/sbin/yarn-daemon.sh
  chmod 0755 /usr/lib/hadoop-yarn/sbin/yarn-daemon.sh
  sudo chown root /usr/lib/hadoop-yarn/sbin/yarn-daemon.sh
  sudo chgrp root /usr/lib/hadoop-yarn/sbin/yarn-daemon.sh
}

#modify httpfs-config.sh
function modhttpfs {
  cp /usr/lib/hadoop/hadoop/libexec/httpfs-config.sh ~/httpfs-config.sh.orig
  #modify by adding env var HTTPFS_LOG=/testhdfsvol/log/httpfs

}

#there is nothing in the site files
#modify hdfs-site.xml,yarn-site.xml, mapred-site.xml
#$1 is /testhdfsvol for blockdev or /var or /var/perf for local
#not true, only works first time changing var to /testhdfsvol; doesnt work converting /testhdfsvol back to original
#there is nothning in these files!
function modsitefiles {
  cd
  if [ -d tmpsite ];then
    rm -rf tmpsite
  fi
  mkdir tmpsite
  sudo cp /etc/hadoop/conf/hdfs-site.xml tmpsite/hdfs-site.xmlorig
  sed 's/var/$1/g' hdfs-site.xmlorig > /etc/hadoop/conf/hdfs-site.xml

  sudo cp /etc/hadoop/conf/mapred-site.xml tmpsite/mapred-site.xmlorig
  sudo sed 's/var/$1/g' mapred-site.xmlorig > /etc/hadoop/conf/mapred-site.xml

  sudo cp /etc/hadoop/conf/yarn-site.xml tmpsite/yarn-site.xmlorig
  sed 's/var/$1/g' yarn-site.xmlorig > /etc/hadoop/conf/yarn-site.xml
}
 
$@
