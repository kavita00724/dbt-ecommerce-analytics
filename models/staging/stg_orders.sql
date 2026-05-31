with source as (
    select * from {{ source('thelook_ecommerce', 'orders') }}
),

renamed as (
    select
        order_id,
        user_id          as customer_id,
        status,
        gender,
        num_of_item,
        created_at       as order_created_at,
        shipped_at,
        delivered_at,
        returned_at
    from source
)

select * from renamed
