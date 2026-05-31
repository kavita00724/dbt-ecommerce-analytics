with order_items as (
    select * from {{ ref('stg_order_items') }}
    where status = 'Complete'
),

products as (
    select * from {{ ref('stg_products') }}
),

product_sales as (
    select
        p.product_id,
        p.product_name,
        p.category,
        p.brand,
        p.department,
        p.retail_price,
        p.cost,
        count(distinct oi.order_id)                                    as total_orders,
        count(oi.order_item_id)                                        as total_units_sold,
        sum(oi.sale_price)                                             as total_revenue,
        avg(oi.sale_price)                                             as avg_sale_price,
        sum(oi.sale_price - p.cost)                                    as total_gross_profit,
        round(
            safe_divide(sum(oi.sale_price - p.cost), sum(oi.sale_price)) * 100,
            2
        )                                                              as gross_margin_pct
    from order_items oi
    left join products p on oi.product_id = p.product_id
    group by 1, 2, 3, 4, 5, 6, 7
)

select * from product_sales
order by total_revenue desc
