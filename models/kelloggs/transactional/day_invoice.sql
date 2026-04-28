{{ config(
    materialized = 'incremental',
    schema = 'transactional',
    unique_key = ['transaction_date', 'cust_number', 'product_id']
) }}

with invoice_raw as (
    select
        date(transaction_timestamp) as transaction_date,
        cust_number,
        product_id,
        quantity,
        region,
        zone
    from {{ source('storage', 'invoice_raw') }}

    {% if is_incremental() %}
        where date(transaction_timestamp) > (
            select max(transaction_date) from {{ this }}
        )
    {% endif %}
),

customer as (
    select
        cust_number,
        cust_name,
        cust_location,
        cust_country_code
    from {{ ref('customer_master') }}
),

product as (
    select
        product_id,
        product_name,
        product_pricing,
        product_margin,
        product_category
    from {{ ref('product_master') }}
),

final as (
    select
        i.transaction_date,
        i.region,
        i.zone,
        i.cust_number,
        c.cust_name,
        c.cust_location,
        c.cust_country_code,
        i.product_id,
        p.product_name,
        p.product_category,
        sum(i.quantity)                                                as total_quantity,
        sum(i.quantity * p.product_pricing)                            as total_value,
        sum((i.quantity * p.product_pricing * p.product_margin) / 100) as total_margin,
        count(*)                                                        as total_order
    from invoice_raw i
    left join customer c on i.cust_number = c.cust_number
    left join product  p on i.product_id  = p.product_id
    group by 1,2,3,4,5,6,7,8,9,10
)

select * from final