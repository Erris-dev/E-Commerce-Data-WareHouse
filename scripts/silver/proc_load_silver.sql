/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver 
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @start_time DATETIME2;
    DECLARE @end_time DATETIME2;
    DECLARE @batch_start DATETIME2;
    
    BEGIN TRY
        PRINT '================================================';
        PRINT 'STARTING SILVER LAYER LOAD';
        PRINT '================================================';
        SET @batch_start = GETDATE();

        --------------------------------------------------------
        -- 1. CUSTOMERS
        --------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Processing: Customers...';

        TRUNCATE TABLE silver.ent_olist_customers;

        INSERT INTO silver.ent_olist_customers (
            customer_id, 
            customer_unique_id, 
            customer_zip_code_prefix, 
            customer_city, 
            customer_state, 
            dwh_load_date
        )
        SELECT 
            customer_id, 
            customer_unique_id, 
            customer_zip_code_prefix, 
            UPPER(TRIM(customer_city)), 
            UPPER(TRIM(customer_state)), 
            GETDATE()
        FROM (
            SELECT *, 
                   ROW_NUMBER() OVER (
                       PARTITION BY customer_unique_id 
                       ORDER BY customer_id DESC
                   ) as row_num 
            FROM bronze.ent_olist_customers
        ) t
        WHERE row_num = 1;

        SET @end_time = GETDATE();
        PRINT '   [OK] Customers loaded in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';


        --------------------------------------------------------
        -- 2. PRODUCTS
        --------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Processing: Products...';

        TRUNCATE TABLE silver.ent_olist_products;

        INSERT INTO silver.ent_olist_products (
            product_id, 
            product_category_name, 
            product_name_length, 
            product_description_length, 
            product_photos_qty, 
            product_weight_g, 
            product_length_cm, 
            product_height_cm, 
            product_width_cm, 
            dwh_load_date
        )
        SELECT 
            p.product_id, 
            UPPER(TRIM(COALESCE(t.product_category_name_english, p.product_category_name, 'UNKNOWN'))) AS category_name, 
            p.product_name_length, 
            p.product_description_length, 
            p.product_photos_qty, 
            p.product_weight_g, 
            p.product_length_cm, 
            p.product_height_cm, 
            p.product_width_cm, 
            GETDATE()
        FROM bronze.ent_olist_products p
        LEFT JOIN bronze.ref_olist_category_name_translation t 
            ON p.product_category_name = t.product_category_name;

        SET @end_time = GETDATE();
        PRINT '   [OK] Products loaded in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';


        --------------------------------------------------------
        -- 3. SELLERS
        --------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Processing: Sellers...';

        TRUNCATE TABLE silver.ent_olist_sellers;

        INSERT INTO silver.ent_olist_sellers (
            seller_id, 
            seller_zip_code_prefix, 
            seller_city, 
            seller_state, 
            dwh_load_date
        )
        SELECT 
            seller_id, 
            seller_zip_code_prefix, 
            UPPER(TRIM(seller_city)), 
            UPPER(TRIM(seller_state)), 
            GETDATE()
        FROM (
            SELECT *, 
                   ROW_NUMBER() OVER (
                       PARTITION BY seller_id 
                       ORDER BY seller_id
                   ) as row_num 
            FROM bronze.ent_olist_sellers
        ) t
        WHERE row_num = 1;

        SET @end_time = GETDATE();
        PRINT '   [OK] Sellers loaded in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';


        --------------------------------------------------------
        -- 4. ORDERS
        --------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Processing: Orders...';

        TRUNCATE TABLE silver.ord_olist_order;

        INSERT INTO silver.ord_olist_order (
            order_id, 
            customer_id, 
            order_status, 
            order_purchase_timestamp, 
            order_approved_at, 
            order_delivered_carrier_date, 
            order_delivered_customer_date, 
            order_estimated_delivery_date, 
            dwh_load_date
        )
        SELECT 
            order_id, 
            customer_id, 
            UPPER(TRIM(order_status)), 
            order_purchase_timestamp, 
            order_approved_at, 
            order_delivered_carrier_date, 
            order_delivered_customer_date, 
            order_estimated_delivery_date, 
            GETDATE()
        FROM (
            SELECT *, 
                   ROW_NUMBER() OVER (
                       PARTITION BY order_id 
                       ORDER BY order_purchase_timestamp DESC
                   ) as row_num 
            FROM bronze.ord_olist_order
        ) t
        WHERE row_num = 1
          AND (
              order_delivered_customer_date IS NULL 
              OR (
                  order_delivered_customer_date >= order_purchase_timestamp 
                  AND DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date) <= 90
              )
          );

        SET @end_time = GETDATE();
        PRINT '   [OK] Orders loaded in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';


        --------------------------------------------------------
        -- 5. ORDER ITEMS
        --------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Processing: Order Items...';

        TRUNCATE TABLE silver.ord_olist_order_items;

        INSERT INTO silver.ord_olist_order_items (
            order_id, 
            order_item_id, 
            product_id, 
            seller_id, 
            shipping_limit_date, 
            price, 
            freight_value, 
            dwh_load_date
        )
        SELECT 
            order_id, 
            order_item_id, 
            product_id, 
            seller_id, 
            shipping_limit_date, 
            price, 
            freight_value, 
            GETDATE()
        FROM (
            SELECT *, 
                   ROW_NUMBER() OVER (
                       PARTITION BY order_id, order_item_id 
                       ORDER BY shipping_limit_date DESC
                   ) as row_num 
            FROM bronze.ord_olist_order_items
        ) t
        WHERE row_num = 1 
          AND price >= 0 
          AND freight_value >= 0;

        SET @end_time = GETDATE();
        PRINT '   [OK] Order Items loaded in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';


        --------------------------------------------------------
        -- 6. PAYMENTS
        --------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Processing: Payments...';

        TRUNCATE TABLE silver.ord_olist_payments;

        INSERT INTO silver.ord_olist_payments (
            order_id, 
            payment_sequential, 
            payment_type, 
            payment_installments, 
            payment_value, 
            dwh_load_date
        )
        SELECT 
            order_id, 
            payment_sequential, 
            UPPER(TRIM(REPLACE(payment_type, '_', ' '))), 
            payment_installments, 
            payment_value, 
            GETDATE()
        FROM (
            SELECT *, 
                   ROW_NUMBER() OVER (
                       PARTITION BY order_id, payment_sequential 
                       ORDER BY payment_value DESC
                   ) as row_num 
            FROM bronze.ord_olist_payments
        ) t
        WHERE row_num = 1 
          AND payment_value >= 0;

        SET @end_time = GETDATE();
        PRINT '   [OK] Payments loaded in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';


        --------------------------------------------------------
        -- 7. REVIEWS
        --------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Processing: Reviews...';

        TRUNCATE TABLE silver.ord_olist_reviews;

        INSERT INTO silver.ord_olist_reviews (
            review_id, 
            order_id, 
            review_score, 
            review_comment_title, 
            review_comment_message, 
            review_creation_date, 
            review_answer_timestamp, 
            dwh_load_date
        )
        SELECT 
            review_id, 
            order_id, 
            review_score, 
            TRIM(review_comment_title), 
            TRIM(review_comment_message), 
            review_creation_date, 
            review_answer_timestamp, 
            GETDATE()
        FROM (
            SELECT *, 
                   ROW_NUMBER() OVER (
                       PARTITION BY review_id, order_id 
                       ORDER BY review_answer_timestamp DESC
                   ) as row_num 
            FROM bronze.ord_olist_reviews
        ) t
        WHERE row_num = 1 
          AND review_score BETWEEN 1 AND 5;

        SET @end_time = GETDATE();
        PRINT '   [OK] Reviews loaded in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';


        --------------------------------------------------------
        -- 8. GEOLOCATION
        --------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Processing: Geolocation...';

        TRUNCATE TABLE silver.ref_olist_geolocation;

        INSERT INTO silver.ref_olist_geolocation (
            geolocation_zip_code_prefix, 
            geolocation_lat, 
            geolocation_lng, 
            geolocation_city, 
            geolocation_state, 
            dwh_load_date
        )
        SELECT 
            geolocation_zip_code_prefix, 
            geolocation_lat, 
            geolocation_lng, 
            UPPER(TRIM(geolocation_city)), 
            UPPER(TRIM(geolocation_state)), 
            GETDATE()
        FROM (
            SELECT *, 
                   ROW_NUMBER() OVER (
                       PARTITION BY geolocation_zip_code_prefix 
                       ORDER BY geolocation_lat DESC
                   ) as row_num 
            FROM bronze.ref_olist_geolocation
        ) t
        WHERE row_num = 1 
          AND geolocation_lat BETWEEN -90 AND 90 
          AND geolocation_lng BETWEEN -180 AND 180;

        SET @end_time = GETDATE();
        PRINT '   [OK] Geolocation loaded in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';


        PRINT '================================================';
        PRINT 'SILVER LAYER LOAD COMPLETED SUCCESSFULLY';
        PRINT 'Total Batch Time: ' + CAST(DATEDIFF(SECOND, @batch_start, GETDATE()) AS VARCHAR) + ' seconds.';
        PRINT '================================================';

    END TRY
    BEGIN CATCH
        PRINT '################################################';
        PRINT 'CRITICAL ERROR DURING LOAD';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR);
        PRINT '################################################';
        
        -- Optional: THROW; // Use THROW if you want the calling application to receive the error
    END CATCH
END;
