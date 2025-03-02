{{
    config(
        materialized='view',
        tags=['intermediate']
    )
}}

with int_sales_margin as (
    select 
        * 
    from 
        {{ ref('int_sales_margin') }}
),
ship as (
    select 
        *
    from 
        {{ ref("stg_gz_ship") }}
),int_orders_operational as (
    select 
        ism.order_id,
        ism.order_date,
        round((ism.margin + s.shipping_fee) - (s.log_cost + s.ship_cost),2) as operational_margin,
        ism.quantity,
        ism.revenue,
        ism.purchase_cost,
        ism.margin,
        s.shipping_fee,
        s.log_cost,
        s.ship_cost
    from 
        int_sales_margin as ism
    join 
        ship as s
    on 
        s.order_id = ism.order_id
)
select 
    order_id,
    order_date,
    operational_margin,
    quantity,
    revenue,
    purchase_cost,
    margin,
    shipping_fee,
    log_cost,
    ship_cost
from 
    int_orders_operational
order by 
    order_id desc
