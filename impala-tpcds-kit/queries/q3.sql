-- start query 1 in stream 0 using template query3.tpl
select
  dt.d_year,
  item.i_brand_id brand_id,
  item.i_brand brand,
  sum(ss_ext_sales_price) sum_agg
from
  date_dim dt,
  store_sales,
  item
where
  dt.d_date_sk = store_sales.ss_sold_date_sk
  and store_sales.ss_item_sk = item.i_item_sk
  and item.i_manufact_id = 436
  and dt.d_moy = 12
  -- partition key filters
  and (ss_sold_date_sk between 2451149 and 2451179
    or ss_sold_date_sk between 2451514 and 2451544
    or ss_sold_date_sk between 2451880 and 2451910
    or ss_sold_date_sk between 2452245 and 2452275
    or ss_sold_date_sk between 2452610 and 2452640)
group by
  dt.d_year,
  item.i_brand,
  item.i_brand_id
order by
  dt.d_year,
  sum_agg desc,
  brand_id
limit 100;
-- end query 1 in stream 0 using template query3.tpl

--
[r2391-d5-us10.dssd.com:21000] > select count(date_dim.d_date_sk) from date_dim,store_sales where date_dim.d_date_sk=store_sales.ss_sold_date_sk limit 10;
Query: select count(date_dim.d_date_sk) from date_dim,store_sales where date_dim.d_date_sk=store_sales.ss_sold_date_sk limit 10
+---------------------------+
| count(date_dim.d_date_sk) |
+---------------------------+
| 17105082                  |
+---------------------------+
Fetched 1 row(s) in 2.53s


[r2391-d5-us10.dssd.com:21000] > 
select date_dim.d_date_sk,store_sales.ss_sold_date_sk,store_sales.ss_item_sk,item.i_item_sk,item.i_manufact_id, date_dim.d_moy from date_dim,store_sales,item  
where date_dim.d_date_sk=store_sales.ss_sold_date_sk 
and store_sales.ss_item_sk=item.i_item_sk 
and item.i_manufact_id=436 
and date_dim.d_moy<10 
and date_dim.d_moy>1 
Fetched 15377 row(s) in 4.59s


select 
  item.i_brand_id brand_id,
  item.i_brand brand,
  sum(ss_ext_sales_price) sum_agg
from date_dim dt,store_sales,item
where dt.d_date_sk=store_sales.ss_sold_date_sk 
and store_sales.ss_item_sk=item.i_item_sk 
and item.i_manufact_id=436 
and dt.d_moy<9 
and dt.d_moy>1
group by
  dt.d_year,
  item.i_brand,
  item.i_brand_id
order by
  dt.d_year,
  sum_agg desc,
  brand_id;
Fetched 122 row(s) in 3.13s (no partition keys for impala/parquet)


NOTE:there are no entries with d_moy=12; something wrong with data population
NOTE:store the data population routines somewhere(in github under hadoop-benchmarks now)
NOTE: experiment with query times when dt.d_moy range is less


select 
  item.i_brand_id brand_id,
  item.i_brand brand,
  sum(ss_ext_sales_price) sum_agg
from date_dim dt,store_sales,item
where dt.d_date_sk=store_sales.ss_sold_date_sk 
and store_sales.ss_item_sk=item.i_item_sk 
and item.i_manufact_id=436 
and dt.d_moy<7 
and dt.d_moy>5
group by
  dt.d_year,
  item.i_brand,
  item.i_brand_id
order by
  dt.d_year,
  sum_agg desc,
  brand_id;
Fetched 122 row(s) in 2.12s


select 
  item.i_brand_id brand_id,
  item.i_brand brand,
  store_sales.ss_sold_date_sk,
  sum(ss_ext_sales_price) sum_agg
from date_dim dt,store_sales,item
where dt.d_date_sk=store_sales.ss_sold_date_sk 
and store_sales.ss_item_sk=item.i_item_sk 
and item.i_manufact_id=436 
and dt.d_moy<9 
and dt.d_moy>1
group by
  dt.d_year,
  store_sales.ss_sold_date_sk,
  item.i_brand,
  item.i_brand_id
order by
  dt.d_year,
  sum_agg desc,
  brand_id;
Fetched 10273 row(s) in 4.85s

