#!/bin/bash -p

# ps -ef | grep cloudera
# kill -9 pids which are running cloudera processes
# bash /home/doug/cleancloudera.sh
# updatedb
# locate cloudera | more
# reboot
# rm -rf /var/run/cloudera-scm-agent ; this should complete if daemons are stopped
#
rm -rf /impala
rm -rf /yarn

rm -rf /usr/java/*

rm -rf /dfs
rm -rf /testhdfsvol/dfs
rm -rf /testhdfsvol/var
rm  /usr/bin/hadoop*
rm /usr/bin/hive*
rm /usr/bin/sqoop*
rm /usr/bin/impala*
rm /usr/bin/spark*
rm /usr/bin/hbase*
rm /usr/bin/sentry
rm /usr/bin/oozie
rm /usr/bin/zookeeper*
rm /usr/bin/solr*
rm /usr/bin/yarn*
rm /usr/bin/pig
rm /usr/bin/pyspark
rm /usr/bin/mahout
rm /usr/bin/mapred
rm /usr/bin/yarn
rm /usr/bin/llama
rm /usr/bin/llamaadmin
rm /usr/bin/flume*
rm /usr/bin/java*

rm -rf /etc/hadoop*
rm -rf /etc/hive*
rm -rf /etc/impala*
rm -rf /etc/flume*
rm -rf /etc/oozie*
rm -rf /etc/spark*
rm -rf /etc/hbase*
rm -rf /etc/hbase*
rm -rf /etc/mahout*
rm -rf  /etc/pig*
rm -rf /etc/sqoop*
rm -rf /etc/sentry
rm -rf /etc/zookeeper
rm -rf /etc/llama
rm -rf /etc/java*

rm /etc/alternatives/hadoop*
rm /etc/alternatives/avro*
rm /etc/alternatives/flume*
rm /etc/alternatives/hbase*
rm /etc/alternatives/hcat*
rm /etc/alternatives/hive*
rm /etc/alternatives/hue*
rm /etc/alternatives/impala*
rm /etc/alternatives/kite*
rm /etc/alternatives/llama*
rm /etc/alternatives/mahout*
rm /etc/alternatives/mapred
rm /etc/alternatives/pig*
rm /etc/alternatives/oozie*
rm /etc/alternatives/solr*
rm /etc/alternatives/sqoop*
rm /etc/alternatives/whirr*
rm /etc/alternatives/yarn
rm /etc/alternatives/zookeeper*
rm /etc/alternatives/sentry*
rm /etc/alternatives/spark*
rm /etc/alternatives/pyspark
rm /etc/alternatives/java*

rm /var/lib/alternatives/java*
rm /var/lib/alternatives/avro*
rm /var/lib/alternatives/beeline
rm /var/lib/alternatives/flume*
rm /var/lib/alternatives/hbase*
rm /var/lib/alternatives/hcat
rm /var/lib/alternatives/hadoop*
rm /var/lib/alternatives/hive*
rm /var/lib/alternatives/sqoop*
rm /var/lib/alternatives/hue*
rm /var/lib/alternatives/impala*
rm /var/lib/alternatives/kite*
rm /var/lib/alternatives/llama*
rm /var/lib/alternatives/mahout*
rm /var/lib/alternatives/mapred*
rm /var/lib/alternatives/pyspark*
rm /var/lib/alternatives/pig*
rm /var/lib/alternatives/oozie*
rm /var/lib/alternatives/sentry*
rm /var/lib/alternatives/solr*
rm /var/lib/alternatives/spark*
rm /var/lib/alternatives/sqoop*
rm /var/lib/alternatives/whirr*
rm /var/lib/alternatives/yarn*
rm /var/lib/alternatives/zookeeper*

rm -rf /var/log/hive*
rm -rf /etc/cloudera-scm-server
rm -rf /etc/default/cloudera-scm-server
rm /etc/rc.d/init.d/cloudera-scm-server*
rm -rf /etc/spark
rm -rf /usr/java/jdk1.7.0_67-cloudera
rm -rf /usr/share/cmf
rm -rf /var/run/cloudera*
rm -rf /etc/cloudera-scm-agent
rm -rf /usr/lib64/cmf
rm /etc/init.d/cloudera-scm-agent
rm -rf /var/lib/cloudera*
rm -rf /var/lib/flume*
rm -rf /var/lib/hadoop*
rm -rf /var/lib/hbase
rm -rf /var/lib/hive
rm -rf /var/lib/impala
rm -rf /var/lib/llama
rm -rf /var/lib/oozie
rm -rf /var/lib/sentry
rm -rf /var/lib/solr
rm -rf /var/lib/spark
rm -rf /var/lib/sqoop*
rm -rf /var/lib/zookeeper
rm -rf /var/log/cloudera*
rm -rf /var/log/hadoop-*
rm -rf /var/log/impalad
rm -rf /etc/security/limits.d/cloudera-scm.conf
rm -rf /etc/yum.repos.d/cloudera*
rm /etc/default/cloudera-scm-agent*
rm /etc/rc.d/rc0.d/*cloudera*
rm /etc/rc.d/rc1.d/*cloudera*
rm /etc/rc.d/rc2.d/*cloudera*
rm /etc/rc.d/rc3.d/*cloudera*
rm /etc/rc.d/rc4.d/*cloudera*
rm /etc/rc.d/rc5.d/*cloudera*
rm /etc/rc.d/rc6.d/*cloudera*
rm -rf /opt/cloudera
rm -rf /etc/hive
rm -rf /etc/hadoop

