/*
===============================================================================
DDL Script: Create Gold Views (Olist Star Schema)
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_key, -- Surrogate key
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix                AS zip_code,
    customer_city                           AS city,
    customer_state                          AS state
FROM silver.ent_olist_customers;
GO

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY product_id) AS product_key, -- Surrogate key
    product_id,
    product_category_name                  AS category,
    product_weight_g                       AS weight_g,
    product_length_cm                      AS length_cm,
    product_height_cm                      AS height_cm,
    product_width_cm                       AS width_cm,
    product_photos_qty                     AS photos_qty
FROM silver.ent_olist_products;
GO

-- =============================================================================
-- Create Dimension: gold.dim_sellers
-- =============================================================================
IF OBJECT_ID('gold.dim_sellers', 'V') IS NOT NULL
    DROP VIEW gold.dim_sellers;
GO

CREATE VIEW gold.dim_sellers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY seller_id) AS seller_key, -- Surrogate key
    seller_id,
    seller_zip_code_prefix                 AS zip_code,
    seller_city                            AS city,
    seller_state                           AS state
FROM silver.ent_olist_sellers;
GO

-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
    sd.order_id,
    sd.order_item_id,
    pr.product_key,  -- Link to Gold Product Dim
    cu.customer_key, -- Link to Gold Customer Dim
    sl.seller_key,   -- Link to Gold Seller Dim
    o.order_purchase_timestamp              AS order_date,
    o.order_approved_at                    AS approved_date,
    o.order_delivered_customer_date         AS delivery_date,
    sd.price                                AS sales_amount,
    sd.freight_value                       AS freight_amount,
    (sd.price + sd.freight_value)          AS total_amount,
    -- Business Logic: Delivery Lead Time
    DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) AS delivery_days
FROM silver.ord_olist_order_items sd
LEFT JOIN silver.ord_olist_order o 
    ON sd.order_id = o.order_id
LEFT JOIN gold.dim_products pr 
    ON sd.product_id = pr.product_id
LEFT JOIN gold.dim_customers cu 
    ON o.customer_id = cu.customer_id
LEFT JOIN gold.dim_sellers sl 
    ON sd.seller_id = sl.seller_id
-- Ensure we only include valid orders from our Silver filtered logic
WHERE o.order_id IS NOT NULL; 
GO

-- =============================================================================
-- Create Fact Table: gold.fact_reviews (Optional Enriched View)
-- =============================================================================
IF OBJECT_ID('gold.fact_reviews', 'V') IS NOT NULL
    DROP VIEW gold.fact_reviews;
GO

CREATE VIEW gold.fact_reviews AS
SELECT
    r.review_id,
    r.order_id,
    r.review_score,
    r.review_creation_date,
    CASE WHEN r.review_comment_message IS NOT NULL THEN 1 ELSE 0 END AS is_commented
FROM silver.ord_olist_reviews r;
GO
