select
  c_last_name,
  c_first_name,
  c_salutation,
  c_preferred_cust_flag,
  ss_ticket_number,
  cnt
from
  (select
    ss_ticket_number,
    ss_customer_sk,
    count(*) cnt
  from
    et_store_sales,
    et_date_dim,
    et_store,
    household_demographics
  where
    et_store_sales.ss_sold_date_sk = et_date_dim.d_date_sk
    and et_store_sales.ss_store_sk = et_store.s_store_sk
    and et_store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    and (et_date_dim.d_dom between 1 and 3
      or et_date_dim.d_dom between 25 and 28)
    and (household_demographics.hd_buy_potential = '>10000'
      or household_demographics.hd_buy_potential = 'unknown')
    and household_demographics.hd_vehicle_count > 0
    and (case when household_demographics.hd_vehicle_count > 0 then household_demographics.hd_dep_count / household_demographics.hd_vehicle_count else null end) > 1.2
    and et_date_dim.d_year in (1998, 1998 + 1, 1998 + 2)
    and et_store.s_county in ('Saginaw County', 'Sumner County', 'Appanoose County', 'Daviess County', 'Fairfield County', 'Raleigh County', 'Ziebach County', 'Williamson County')
    and ss_sold_date_sk between 2450816 and 2451910 -- partition key filter
  group by
    ss_ticket_number,
    ss_customer_sk
  ) dn,
  customer
where
  ss_customer_sk = c_customer_sk
  and cnt between 15 and 20
order by
  c_last_name,
  c_first_name,
  c_salutation,
  c_preferred_cust_flag desc
limit 100000;
