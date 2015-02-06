select
  dt.d_year,
  item.i_category_id,
  item.i_category,
  sum(ss_ext_sales_price)
from
  et_date_dim dt,
  et_store_sales,
  item
where
  dt.d_date_sk = et_store_sales.ss_sold_date_sk
  and et_store_sales.ss_item_sk = item.i_item_sk
  and item.i_manager_id = 1
  and dt.d_moy = 12
  and dt.d_year = 1998
  and ss_sold_date_sk between 2451149 and 2451179  -- partition key filter
group by
  dt.d_year,
  item.i_category_id,
  item.i_category
order by
  sum(ss_ext_sales_price) desc,
  dt.d_year,
  item.i_category_id,
  item.i_category
limit 100;
