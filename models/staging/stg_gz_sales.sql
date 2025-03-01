with stg_gz_sales as (
        select * from {{ source('raw_gz_data', 'raw_gz_sales') }}
  )
  select 
    date_date as order_date,
    orders_id as order_id,
    pdt_id as product_id,
    revenue as price,
    quantity
  from 
    stg_gz_sales
    