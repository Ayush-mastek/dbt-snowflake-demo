{{ config(
    materialized = 'view',
    schema = 'master'
) }}

with kna1 as (
    select
        cust_number,
        cust_location,
        cust_country,
        validity_start,
        validity_end
    from {{ source('stage', 'cust_mstr_kna1') }}
),

tkna1 as (
    select
        cust_number,
        first_name || ' ' || last_name as cust_name
    from {{ source('stage', 'cust_mstr_tkna1') }}
),

latest_location as (
    select
        cust_number,
        cust_location,
        row_number() over (
            partition by cust_number
            order by validity_end desc
        ) as rn
    from kna1
),

country_codes as (
    select
        country_name,
        country_code
    from {{ ref('country_code') }}
    where country_code not in ('+7', '+92')
),

final as (
    select
        k.cust_number,
        n.cust_name,
        ll.cust_location,
        k.cust_country,
        cc.country_code as cust_country_code
    from kna1 k
    left join tkna1 n
        on k.cust_number = n.cust_number
    left join latest_location ll
        on k.cust_number = ll.cust_number
        and ll.rn = 1
    left join country_codes cc
        on k.cust_country = cc.country_name
    qualify row_number() over (
        partition by k.cust_number
        order by k.validity_end desc
    ) = 1
)

select * from final