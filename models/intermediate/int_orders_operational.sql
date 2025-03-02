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
),
int_orders_operational as (
    select 
        ism.order_id,                      --order identifier
        ism.order_date,                    --order date
        round(
            (ism.margin + s.shipping_fee) 
            - 
            (s.log_cost + s.ship_cost)
            ,2) as operational_margin,     --profit Greenweez makes on the sale of products in an order after operational and logistics costs
        ism.quantity,                      --quantity of products in an order
        ism.revenue,                       --price paid by customer to purchase all products in an order     
        ism.purchase_cost,                 --Greenweez cost to obtain the products in an order
        ism.margin,                        --profit Greenweez makes on the sale of products in an order, not accounting for operational and logistics costs                  
        s.shipping_fee,                    --fee customer pays for shipping an order
        s.log_cost,                        --Greenweez cost to prepare the parcel for delivery 
        s.ship_cost                        --Greenweez shipping cost paid to logistics provider to deliver order 
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
