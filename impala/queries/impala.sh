#!/bin/bash -p


impala-shell -d tpcds_parquet -f q3.sql -o impalaoutput.txt

