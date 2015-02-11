#!/bin/bash

#have to remove from root node and agents. Different
sudo rm -Rf /usr/share/cmf
sudo rm -Rf /var/lib/cloudera*
sudo rm -Rf /var/log/cloudera*
sudo rm -Rf /var/lib/flume-ng
sudo rm -Rf /var/lib/hadoop*
sudo rm -Rf /var/lib/oozie
sudo rm -Rf /var/lib/solr
sudo rm -Rf /var/lib/sqoop*
sudo rm -Rf /var/cache/yum/cloudera*
sudo /usr/share/cmf/uninstall-cloudera-manager.sh


