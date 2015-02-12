#!/bin/bash -p

#set swappiness using sysctl vm.swappiness=0
#dont change the /etc/sysctl.conf file; will mess up others
ssh root@r2391-d5-us01 "sysctl vm.swappiness=0"
ssh root@r2291-d5-us02 "sysctl vm.swappiness=0"
ssh root@r2391-d5-us03 "sysctl vm.swappiness=0"
ssh root@r2391-d5-us04 "sysctl vm.swappiness=0"
ssh root@r2391-d5-us09 "sysctl vm.swappiness=0"
ssh root@r2391-d5-us10 "sysctl vm.swappiness=0"
ssh root@r2391-d5-us11 "sysctl vm.swappiness=0"
ssh root@r2391-d5-us12 "sysctl vm.swappiness=0"
ssh root@r2391-d5-us13 "sysctl vm.swappiness=0"
ssh root@r2391-d5-us14 "sysctl vm.swappiness=0"

ssh root@r2391-d5-us01 "echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag"
ssh root@r2391-d5-us02 "echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag"
ssh root@r2391-d5-us03 "echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag"
ssh root@r2391-d5-us04 "echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag"
ssh root@r2391-d5-us09 "echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag"
ssh root@r2391-d5-us10 "echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag"
ssh root@r2391-d5-us11 "echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag"
ssh root@r2391-d5-us12 "echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag"
ssh root@r2391-d5-us13 "echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag"
ssh root@r2391-d5-us14 "echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag"
