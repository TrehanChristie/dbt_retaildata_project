{{
    config(
        materialized='view',
        tags=['marts']
    )
}}

with int_orders_operational as (
    select
        *
    from 
        {{ ref("int_orders_operational") }}
), 
finance_days as (
    select 
        order_date                                                  --date
        ,COUNT(order_id) AS nb_transactions                         --daily number of orders
        ,SUM(quantity) AS quantity                                  --daily quantity of all products sold
        ,ROUND(SUM(revenue), 2) AS revenue                          --daily price paid by customers for all products sold
        ,ROUND(AVG(revenue), 2) AS average_basket                   --daily average order revenue
        ,ROUND(SUM(margin), 2) AS margin                            --daily profit Greenweez makes on orders
        ,ROUND(SUM(operational_margin), 2) AS operational_margin    --daily profit Greenweez makes on an orders after operational and logistics costs
        ,ROUND(SUM(purchase_cost), 2) AS purchase_cost              --daily Greenweez cost to obtain the products sold
        ,ROUND(SUM(shipping_fee), 2) AS shipping_fee                --daily total price paid by all customers for shipping
        ,ROUND(SUM(log_cost), 2) AS log_cost                        --daily Greenweez cost to prepare parcels for delivery
        ,ROUND(SUM(ship_cost), 2) AS ship_cost                      --daily Greenweez cost paid to logistics providers to deliver orders
    from  
        int_orders_operational as ioo
    group by 
        order_date
)
select 
    order_date          
    ,nb_transactions    
    ,quantity           
    ,revenue            
    ,average_basket     
    ,margin             
    ,operational_margin 
    ,purchase_cost      
    ,shipping_fee       
    ,log_cost           
    ,ship_cost          
from 
    finance_days
order by 
    order_date desc
