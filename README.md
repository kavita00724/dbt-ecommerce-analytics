# dbt E-Commerce Analytics

A dbt project modeling e-commerce KPIs using the [Google `thelook_ecommerce` public dataset](https://console.cloud.google.com/marketplace/product/bigquery-public-data/thelook-ecommerce) on BigQuery.

## Project Overview

This project transforms raw e-commerce data into analytics-ready models covering customer lifetime value, cohort retention, and product revenue — the core metrics used in data-driven merchandising and retention strategy.

## Data Sources

All source data comes from `bigquery-public-data.thelook_ecommerce`:

| Table | Description |
|---|---|
| `orders` | One record per order placed |
| `order_items` | One record per line item within an order |
| `users` | Customer profile and acquisition data |
| `products` | Product catalog with cost and retail price |

## Model Layers

```
models/
├── staging/          # Light transformations on raw source tables (views)
│   ├── stg_orders
│   ├── stg_order_items
│   ├── stg_customers
│   └── stg_products
└── marts/            # Business logic models for stakeholders (tables)
    ├── customer_lifetime_value
    ├── order_cohort_analysis
    └── product_revenue
```

### Staging Layer
Renames columns, casts data types, and cleans raw data. No joins or business logic. Every downstream model builds on staging only.

### Marts Layer

**`customer_lifetime_value`**
One record per customer with total orders, total revenue, average item value, customer lifespan, and a CLV segment (High / Mid / Low Value). Directly supports retention and personalisation strategy.

**`order_cohort_analysis`**
Monthly cohort retention table. For each acquisition cohort, tracks how many customers returned to purchase in each subsequent month and calculates the retention rate percentage.

**`product_revenue`**
One record per product with units sold, total revenue, gross profit, and gross margin percentage. Supports merchandising prioritisation and pricing decisions.

## DAG

```
[Source: thelook_ecommerce]
        │
        ├── stg_orders
        ├── stg_order_items ──────────┬──── customer_lifetime_value
        ├── stg_customers ────────────┤──── order_cohort_analysis
        └── stg_products ────────────┴──── product_revenue
```

## Tests

All models include dbt data tests:
- `unique` + `not_null` on all primary keys
- `not_null` on critical foreign keys and metric columns
- `accepted_values` on status and segment columns
- `relationships` tests to enforce referential integrity

```bash
dbt test                          # run all tests
dbt test --select source:*        # source tests only
dbt test --select marts/*         # mart tests only
```

## Setup

**Requirements:** Python 3.9+, a Google Cloud account with BigQuery access.

1. Clone the repo and create a virtual environment:
```bash
git clone https://github.com/kavita00724/dbt-ecommerce-analytics.git
cd dbt-ecommerce-analytics
python3 -m venv venv && source venv/bin/activate
pip install dbt-bigquery
```

2. Copy `profiles.yml.example` to `~/.dbt/profiles.yml` and fill in your GCP project ID.

3. Authenticate with Google Cloud:
```bash
gcloud auth application-default login
```

4. Run the project:
```bash
dbt build
```

## Tech Stack

- **Transformation:** dbt Core 1.11
- **Warehouse:** Google BigQuery
- **Source dataset:** `bigquery-public-data.thelook_ecommerce`
- **Language:** SQL
