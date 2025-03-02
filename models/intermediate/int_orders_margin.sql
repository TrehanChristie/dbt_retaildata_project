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
)
select 
    order_id,
    max(order_date) as order_date,
    ROUND(SUM(revenue),2) as revenue,
    ROUND(SUM(quantity),2) as quantity,
    ROUND(SUM(purchase_cost),2) as purchase_cost,
    ROUND(SUM(margin),2) as margin
from 
    int_sales_margin
group by 
    order_id
order by 
     order_id desc