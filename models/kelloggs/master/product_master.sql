{{ config(
    materialized = 'view',
    schema = 'master'
) }}

with pna1 as (
    select
        product_id,
        product_pricing,
        product_margin,
        date,
        category_code
    from {{ source('stage', 'prod_mstr_pna1') }}
),

tpna1 as (
    select
        product_id,
        product_name
    from {{ source('stage', 'prod_mstr_tpna1') }}
),

final as (
    select
        p.product_id,
        t.product_name,
        p.product_pricing,
        p.product_margin,
        p.date,
        case
            when p.category_code = 1 then 'Snacks'
            when p.category_code = 2 then 'Cereal'
            else 'Unknown'
        end as product_category
    from pna1 p
    left join tpna1 t
        on p.product_id = t.product_id
)

select * from final