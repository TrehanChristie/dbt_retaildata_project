{{
    config(
        materialized='view',
        tags=['intermediate']
    )
}}

with sales as (
    select 
        * 
    from 
        {{ ref('stg_gz_sales') }}
), 
product as (
    select 
        * 
    from 
        {{ ref('stg_gz_product') }}
), 
int_sales_margin as (
    select 
        sales.*
        ,ROUND(quantity * purchase_price,2) as purchase_cost
        ,ROUND(revenue - (quantity * purchase_price),2) as margin
        ,{{ margin_percent('sales.revenue', 'sales.quantity') }} AS margin_percent
        ,product.purchase_price
    from 
        sales
    join 
        product
    on 
        sales.product_id = product.product_id
)
select 
    product_id,
    order_id,
    order_date,
    revenue,
    quantity,
    purchase_price,
    purchase_cost,
    margin,
    margin_percent
from 
    int_sales_margin 
order by 
    order_date desc