{{
    config(
        materialized='view',
        tags=['intermediate']
    )
}}

with int_orders_margin as (
    select 
        * 
    from 
        {{ ref('int_orders_margin') }}
),
ship as (
    select 
        *
    from 
        {{ ref("stg_gz_ship") }}
),
int_orders_operational as (
    select 
        iom.order_id,                      --order identifier
        iom.order_date,                    --order date
        round(
            (iom.margin + s.shipping_fee) 
            - 
            (s.log_cost + s.ship_cost)
            ,2) as operational_margin,     --profit Greenweez makes on the sale of products in an order after operational and logistics costs
        iom.quantity,                      --quantity of products in an order
        iom.revenue,                       --price paid by customer to purchase all products in an order     
        iom.purchase_cost,                 --Greenweez cost to obtain the products in an order
        iom.margin,                        --profit Greenweez makes on the sale of products in an order, not accounting for operational and logistics costs                  
        s.shipping_fee,                    --fee customer pays for shipping an order
        s.log_cost,                        --Greenweez cost to prepare the parcel for delivery 
        s.ship_cost                        --Greenweez shipping cost paid to logistics provider to deliver order 
    from 
        int_orders_margin as iom
    join 
        ship as s
    on 
        s.order_id = iom.order_id
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
