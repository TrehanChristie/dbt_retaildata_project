with stg_gz_product as (
        select * from {{ source('raw_gz_data', 'raw_gz_product') }}
  )
  select 
    products_id as product_id, 
    cast(purchSE_PRICE as FLOAT64) as purchase_price
  from 
    stg_gz_product
    