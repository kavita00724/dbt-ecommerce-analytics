with customers as (
    select
        customer_id,
        timestamp_trunc(customer_created_at, month) as cohort_month
    from {{ ref('stg_customers') }}
),

completed_orders as (
    select
        customer_id,
        timestamp_trunc(order_item_created_at, month) as order_month
    from {{ ref('stg_order_items') }}
    where status = 'Complete'
),

cohort_activity as (
    select
        c.customer_id,
        c.cohort_month,
        o.order_month,
        date_diff(
            date(o.order_month),
            date(c.cohort_month),
            month
        ) as months_since_acquisition
    from customers c
    inner join completed_orders o on c.customer_id = o.customer_id
),

cohort_sizes as (
    select
        cohort_month,
        count(distinct customer_id) as cohort_size
    from customers
    group by cohort_month
),

retention as (
    select
        ca.cohort_month,
        ca.months_since_acquisition,
        count(distinct ca.customer_id)  as active_customers
    from cohort_activity ca
    group by ca.cohort_month, ca.months_since_acquisition
),

final as (
    select
        r.cohort_month,
        r.months_since_acquisition,
        r.active_customers,
        cs.cohort_size,
        round(
            safe_divide(r.active_customers, cs.cohort_size) * 100,
            2
        ) as retention_rate_pct
    from retention r
    left join cohort_sizes cs on r.cohort_month = cs.cohort_month
)

select * from final
order by cohort_month, months_since_acquisition
