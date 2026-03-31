
/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

-- 1. Customers
IF OBJECT_ID ('bronze.ent_olist_customers', 'U') IS NOT NULL DROP TABLE bronze.ent_olist_customers;
GO
CREATE TABLE bronze.ent_olist_customers (
    customer_id              VARCHAR(50), 
    customer_unique_id       VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city            VARCHAR(150), 
    customer_state           VARCHAR(50)
);

-- 2. Products
IF OBJECT_ID ('bronze.ent_olist_products', 'U') IS NOT NULL DROP TABLE bronze.ent_olist_products;
GO
CREATE TABLE bronze.ent_olist_products (
    product_id                 VARCHAR(50),
    product_category_name      VARCHAR(150),
    product_name_length        INT,
    product_description_length INT,
    product_photos_qty         INT,
    product_weight_g           INT,
    product_length_cm          INT,
    product_height_cm          INT,
    product_width_cm           INT
);

-- 3. Sellers
IF OBJECT_ID ('bronze.ent_olist_sellers', 'U') IS NOT NULL DROP TABLE bronze.ent_olist_sellers;
GO
CREATE TABLE bronze.ent_olist_sellers (
    seller_id              VARCHAR(50),
    seller_zip_code_prefix INT,
    seller_city            VARCHAR(150),
    seller_state           VARCHAR(50)
);

-- 4. Order Items
IF OBJECT_ID ('bronze.ord_olist_order_items', 'U') IS NOT NULL DROP TABLE bronze.ord_olist_order_items;
GO
CREATE TABLE bronze.ord_olist_order_items (
    order_id            VARCHAR(50),
    order_item_id       INT,
    product_id          VARCHAR(50),
    seller_id           VARCHAR(50),
    shipping_limit_date DATETIME2(0),
    price               DECIMAL(10,2),
    freight_value       DECIMAL(10,2)
);

-- 5. Payments
IF OBJECT_ID ('bronze.ord_olist_payments', 'U') IS NOT NULL DROP TABLE bronze.ord_olist_payments;
GO
CREATE TABLE bronze.ord_olist_payments (
    order_id             VARCHAR(50),
    payment_sequential   INT,
    payment_type         VARCHAR(50),
    payment_installments INT,
    payment_value        DECIMAL(10,2)
);

-- 6. Reviews
IF OBJECT_ID ('bronze.ord_olist_reviews', 'U') IS NOT NULL DROP TABLE bronze.ord_olist_reviews;
GO
CREATE TABLE bronze.ord_olist_reviews (
    review_id               VARCHAR(50),
    order_id                VARCHAR(50),
    review_score            INT,
    review_comment_title    VARCHAR(MAX),
    review_comment_message  VARCHAR(MAX),
    review_creation_date    DATETIME2,
    review_answer_timestamp DATETIME2
);

-- 7. Orders (The Hub)
IF OBJECT_ID ('bronze.ord_olist_order', 'U') IS NOT NULL DROP TABLE bronze.ord_olist_order;
GO
CREATE TABLE bronze.ord_olist_order (
    order_id                         VARCHAR(50),
    customer_id                      VARCHAR(50),
    order_status                     VARCHAR(50),
    order_purchase_timestamp         DATETIME2(0),
    order_approved_at                DATETIME2(0),
    order_delivered_carrier_date     DATETIME2(0),
    order_delivered_customer_date    DATETIME2(0),
    order_estimated_delivery_date    DATETIME2(0)
);

-- 8. Geolocation
IF OBJECT_ID ('bronze.ref_olist_geolocation', 'U') IS NOT NULL DROP TABLE bronze.ref_olist_geolocation;
GO
CREATE TABLE bronze.ref_olist_geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat             DECIMAL(18,15),
    geolocation_lng             DECIMAL(18,15),
    geolocation_city            VARCHAR(150),
    geolocation_state           VARCHAR(50)
);

-- 9. Category Translation
IF OBJECT_ID ('bronze.ref_olist_category_name_translation', 'U') IS NOT NULL DROP TABLE bronze.ref_olist_category_name_translation;
GO
CREATE TABLE bronze.ref_olist_category_name_translation (
    product_category_name         VARCHAR(150),
    product_category_name_english VARCHAR(150)
);
