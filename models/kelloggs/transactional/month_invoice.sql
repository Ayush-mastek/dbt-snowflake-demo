{{ config(
    materialized = 'table',
    schema = 'transactional'
) }}

with day_data as (
    select
        date_trunc('month', transaction_date) as transaction_month,
        region,
        zone,
        cust_number,
        cust_name,
        cust_location,
        cust_country_code,
        product_id,
        product_name,
        product_category,
        total_quantity,
        total_value,
        total_margin,
        total_order
    from {{ ref('day_invoice') }}
),

final as (
    select
        transaction_month,
        region,
        zone,
        cust_number,
        cust_name,
        cust_location,
        cust_country_code,
        product_id,
        product_name,
        product_category,
        sum(total_quantity) as total_quantity,
        sum(total_value)    as total_value,
        sum(total_margin)   as total_margin,
        sum(total_order)    as total_order
    from day_data
    group by 1,2,3,4,5,6,7,8,9,10
)

select * from final
