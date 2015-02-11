#!/bin/bash

#have to remove from root node and agents. Different

sudo rm -Rf /etc/cloudera*
sudo rm -Rf /opt/cloudera

sudo rm -Rf /testhdfsvol/dfs
sudo rm -Rf /testhdfsvol/var
sudo rm -Rf /testhdfsvol/yarn

sudo rm -Rf /usr/share/cmf

sudo rm -Rf /var/lib/cloudera*
sudo rm -Rf /var/lib/hadoop*
sudo rm -Rf /var/lib/flume*
sudo rm -Rf /var/lib/flume-ng
sudo rm -Rf /var/lib/hbase
sudo rm -Rf /var/lib/hive
sudo rm -Rf /var/lib/impala*
sudo rm -Rf /var/lib/llama
sudo rm -Rf /var/lib/oozie
sudo rm -Rf /var/lib/pgsql
sudo rm -Rf /var/lib/solr
sudo rm -Rf /var/lib/sentry
sudo rm -Rf /var/lib/sqoop*
sudo rm -Rf /var/lib/spark
sudo rm -Rf /var/lib/zookeeper
sudo rm -Rf /var/lib/stateless
sudo rm -Rf /var/lib/oozie

sudo rm -Rf /var/log/cloudera*
sudo rm -Rf /var/log/hadoop*
sudo rm -Rf /var/log/hive
sudo rm -Rf /var/log/statestore
sudo rm -Rf /var/log/impala*

sudo rm -Rf /var/cache/yum/cloudera*
#sudo /usr/share/cmf/uninstall-cloudera-manager.sh


