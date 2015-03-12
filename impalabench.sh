#!/bin/bash -p


#impala-shell -d tpcds_parquet -f q19.sql -o impalaoutput.txt

cd ~/impala-tpcds-kit/queries
for queryfile in $( ls *.sql ); do
  echo "processing $queryfile"
  time impala-shell -d tpcds_parquet -f $queryfile -o impalaoutput$queryfile.txt
done


