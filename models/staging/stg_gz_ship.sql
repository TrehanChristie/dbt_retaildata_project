{{
    config(
        materialized='view',
        tags=['staging']
    )
}}

with stg_gz_ship as (
        select * from {{ source('raw_gz_data', 'raw_gz_ship') }}
  )
  select 
    orders_id as order_id,
    shipping_fee,
    logCost as log_cost,
    cast(ship_cost as int) as ship_cost
  from 
    stg_gz_ship
    