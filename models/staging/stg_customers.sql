with source as (
    select * from {{ source('thelook_ecommerce', 'users') }}
),

renamed as (
    select
        id               as customer_id,
        first_name,
        last_name,
        email,
        age,
        gender,
        country,
        city,
        traffic_source,
        created_at       as customer_created_at
    from source
)

select * from renamed
