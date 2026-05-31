with customers as (
    select * from {{ ref('stg_customers') }}
),

completed_items as (
    select * from {{ ref('stg_order_items') }}
    where status = 'Complete'
),

customer_orders as (
    select
        customer_id,
        count(distinct order_id)                                    as total_orders,
        count(order_item_id)                                        as total_items_purchased,
        sum(sale_price)                                             as total_revenue,
        avg(sale_price)                                             as avg_item_value,
        min(order_item_created_at)                                  as first_order_at,
        max(order_item_created_at)                                  as last_order_at,
        date_diff(
            date(max(order_item_created_at)),
            date(min(order_item_created_at)),
            day
        )                                                           as customer_lifespan_days
    from completed_items
    group by customer_id
),

final as (
    select
        c.customer_id,
        c.first_name,
        c.last_name,
        c.email,
        c.country,
        c.traffic_source,
        c.customer_created_at,
        coalesce(co.total_orders, 0)           as total_orders,
        coalesce(co.total_items_purchased, 0)  as total_items_purchased,
        coalesce(co.total_revenue, 0)          as total_revenue,
        co.avg_item_value,
        co.first_order_at,
        co.last_order_at,
        coalesce(co.customer_lifespan_days, 0) as customer_lifespan_days,
        case
            when coalesce(co.total_revenue, 0) >= 500 then 'High Value'
            when coalesce(co.total_revenue, 0) >= 150 then 'Mid Value'
            else 'Low Value'
        end                                    as clv_segment
    from customers c
    left join customer_orders co on c.customer_id = co.customer_id
)

select * from final
