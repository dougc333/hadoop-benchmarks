#!/bin/bash -p


res1=$(impala-shell --database=tpcds_parquet --query_file=q19.sql)
echo "res1: "$res1
res2=$(impala-shell --database=tpcds_parquet --query_file=q34.sql)
res3=$(impala-shell --database=tpcds_parquet --query_file=q42.sql)
res4=$(impala-shell --database=tpcds_parquet --query_file=q46.sql)
res5=$(impala-shell --database=tpcds_parquet --query_file=q53.sql)
res6=$(impala-shell --database=tpcds_parquet --query_file=q59.sql)
res7=$(impala-shell --database=tpcds_parquet --query_file=q65.sql)
res8=$(impala-shell --database=tpcds_parquet --query_file=q73.sql)
res9=$(impala-shell --database=tpcds_parquet --query_file=q7.sql)
res10=$(impala-shell --database=tpcds_parquet --query_file=q98.sql)
res11=$(impala-shell --database=tpcds_parquet --query_file=q27.sql)
res12=$(impala-shell --database=tpcds_parquet --query_file=q3.sql)
res13=$(impala-shell --database=tpcds_parquet --query_file=q43.sql)
res14=$(impala-shell --database=tpcds_parquet --query_file=q52.sql)
res15=$(impala-shell --database=tpcds_parquet --query_file=q55.sql)
res16=$(impala-shell --database=tpcds_parquet --query_file=q63.sql)
res17=$(impala-shell --database=tpcds_parquet --query_file=q68.sql)
res18=$(impala-shell --database=tpcds_parquet --query_file=q79.sql)
res19=$(impala-shell --database=tpcds_parquet --query_file=q89.sql)
res20=$(impala-shell --database=tpcds_parquet --query_file=ss_max.sql)
