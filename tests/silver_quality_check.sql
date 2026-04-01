/*
===============================================================================
Quality Checks: Silver Layer Validation
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency (Casing/Formatting).
    - Invalid date ranges and orders.
    - Data consistency between related fields (Referential Integrity).

Usage Notes:
    - Run these checks after loading the Silver Layer using silver.load_silver.
    - If any query returns rows, investigate the source data in Bronze or 
      the transformation logic in your stored procedure.
===============================================================================
*/

-------------------------------------------------------------------------------
-- 1. PRIMARY KEY UNIQUENESS CHECKS
-- Purpose: Ensures that deduplication logic (ROW_NUMBER) worked correctly.
-------------------------------------------------------------------------------

-- Duplicate Customers
SELECT 'Duplicate Customer ID' AS Issue, customer_id, COUNT(*) AS Occurrence
FROM silver.ent_olist_customers 
GROUP BY customer_id 
HAVING COUNT(*) > 1;

-- Duplicate Orders
SELECT 'Duplicate Order ID' AS Issue, order_id, COUNT(*) AS Occurrence
FROM silver.ord_olist_order 
GROUP BY order_id 
HAVING COUNT(*) > 1;

-- Duplicate Sellers
SELECT 'Duplicate Seller ID' AS Issue, seller_id, COUNT(*) AS Occurrence
FROM silver.ent_olist_sellers 
GROUP BY seller_id 
HAVING COUNT(*) > 1;

-- Duplicate Order Items (Composite Key)
SELECT 'Duplicate Item ID per Order' AS Issue, order_id, order_item_id, COUNT(*) AS Occurrence
FROM silver.ord_olist_order_items 
GROUP BY order_id, order_item_id 
HAVING COUNT(*) > 1;


-------------------------------------------------------------------------------
-- 2. NULL VALUE CHECKS
-- Purpose: Ensures critical "Foreign Keys" and mandatory fields are not empty.
-------------------------------------------------------------------------------

SELECT 'NULL in Product ID' as Issue, COUNT(*) as Count FROM silver.ent_olist_products WHERE product_id IS NULL
UNION ALL
SELECT 'NULL in Order Status', COUNT(*) FROM silver.ord_olist_order WHERE order_status IS NULL
UNION ALL
SELECT 'NULL in Payment Type', COUNT(*) FROM silver.ord_olist_payments WHERE payment_type IS NULL;


-------------------------------------------------------------------------------
-- 3. DATA STANDARDIZATION & STRING CLEANING
-- Purpose: Ensures TRIM and UPPER transformations were applied.
-------------------------------------------------------------------------------

-- Check for untrimmed city names in Customers
SELECT 'Untrimmed/Non-Upper City' as Issue, customer_city 
FROM silver.ent_olist_customers 
WHERE customer_city != UPPER(TRIM(customer_city)) COLLATE Latin1_General_BIN2;

-- Check for underscores in Payment Types (should be replaced with spaces)
SELECT 'Improper Payment Format' as Issue, payment_type 
FROM silver.ord_olist_payments 
WHERE payment_type LIKE '%\_%' ESCAPE '\';


-------------------------------------------------------------------------------
-- 4. DATE LOGIC & OUTLIER VALIDATION
-- Purpose: Validates that dates are chronologically sound and within "Option 3" limits.
-------------------------------------------------------------------------------

-- Delivery date should never be earlier than purchase date
SELECT 'Negative Delivery Time' as Issue, order_id, order_purchase_timestamp, order_delivered_customer_date
FROM silver.ord_olist_order
WHERE order_delivered_customer_date < order_purchase_timestamp;

-- Ensure our 90-day outlier filter was respected
SELECT 'Delivery Outlier (>90 days)' as Issue, order_id, DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date) as Days
FROM silver.ord_olist_order
WHERE DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date) > 90;


-------------------------------------------------------------------------------
-- 5. FINANCIAL INTEGRITY CHECKS
-- Purpose: Ensures price, freight, and payments are not negative.
-------------------------------------------------------------------------------

SELECT 'Negative Price' as Issue, order_id, price FROM silver.ord_olist_order_items WHERE price < 0
UNION ALL
SELECT 'Negative Freight', order_id, freight_value FROM silver.ord_olist_order_items WHERE freight_value < 0
UNION ALL
SELECT 'Negative Payment', order_id, payment_value FROM silver.ord_olist_payments WHERE payment_value < 0;


-------------------------------------------------------------------------------
-- 6. REFERENTIAL INTEGRITY (ORPHANED RECORDS)
-- Purpose: Ensures that child tables point to valid parent records.
-------------------------------------------------------------------------------

-- Orders with no matching Customer
SELECT 'Orphaned Order (No Customer)' as Issue, COUNT(*) as Count
FROM silver.ord_olist_order o 
LEFT JOIN silver.ent_olist_customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Order Items with no matching Product
SELECT 'Orphaned Item (No Product)' as Issue, COUNT(*) as Count
FROM silver.ord_olist_order_items i
LEFT JOIN silver.ent_olist_products p ON i.product_id = p.product_id
WHERE p.product_id IS NULL;


-------------------------------------------------------------------------------
-- 7. REVIEWS VALIDATION
-- Purpose: Ensures star ratings are strictly within the 1-5 range.
-------------------------------------------------------------------------------

SELECT 'Invalid Review Score' as Issue, review_id, review_score
FROM silver.ord_olist_reviews
WHERE review_score < 1 OR review_score > 5;
