/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    SET NOCOUNT ON;

    PRINT '================================================';
    PRINT 'Starting Bronze Layer Load: ' + CAST(GETDATE() AS VARCHAR);
    PRINT '================================================';

    BEGIN TRY
        -- 1. Customers
        PRINT '>> Loading: bronze.ent_olist_customers...';
        TRUNCATE TABLE bronze.ent_olist_customers;
        BULK INSERT bronze.ent_olist_customers
        FROM 'C:\Users\erris\OneDrive\Desktop\E-Commerce-Data-WareHouse\datasets\source_ent\olist_customers_dataset.csv'
        WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK);
        PRINT '   [SUCCESS] Customers loaded.';

        -- 2. Products
        PRINT '>> Loading: bronze.ent_olist_products...';
        TRUNCATE TABLE bronze.ent_olist_products;
        BULK INSERT bronze.ent_olist_products
        FROM 'C:\Users\erris\OneDrive\Desktop\E-Commerce-Data-WareHouse\datasets\source_ent\olist_products_dataset.csv'
        WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK);
        PRINT '   [SUCCESS] Products loaded.';

        -- 3. Sellers
        PRINT '>> Loading: bronze.ent_olist_sellers...';
        TRUNCATE TABLE bronze.ent_olist_sellers;
        BULK INSERT bronze.ent_olist_sellers
        FROM 'C:\Users\erris\OneDrive\Desktop\E-Commerce-Data-WareHouse\datasets\source_ent\olist_sellers_dataset.csv'
        WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK);
        PRINT '   [SUCCESS] Sellers loaded.';

        -- 4. Payments
        PRINT '>> Loading: bronze.ord_olist_payments...';
        TRUNCATE TABLE bronze.ord_olist_payments;
        BULK INSERT bronze.ord_olist_payments
        FROM 'C:\Users\erris\OneDrive\Desktop\E-Commerce-Data-WareHouse\datasets\source_ord\olist_order_payments_dataset.csv'
        WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK);
        PRINT '   [SUCCESS] Payments loaded.';

        -- 5. Order Items
        PRINT '>> Loading: bronze.ord_olist_order_items...';
        TRUNCATE TABLE bronze.ord_olist_order_items;
        BULK INSERT bronze.ord_olist_order_items
        FROM 'C:\Users\erris\OneDrive\Desktop\E-Commerce-Data-WareHouse\datasets\source_ord\olist_order_items_dataset.csv'
        WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK);
        PRINT '   [SUCCESS] Order Items loaded.';

        -- 6. Reviews (The Tricky One)
        PRINT '>> Loading: bronze.ord_olist_reviews...';
        TRUNCATE TABLE bronze.ord_olist_reviews;
        BULK INSERT bronze.ord_olist_reviews
        FROM 'C:\Users\erris\OneDrive\Desktop\E-Commerce-Data-WareHouse\datasets\source_ord\olist_order_reviews_dataset.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2, 
            CODEPAGE = '65001', 
            TABLOCK
        );
        PRINT '   [SUCCESS] Reviews loaded.';

        -- 7. Orders
        PRINT '>> Loading: bronze.ord_olist_order...';
        TRUNCATE TABLE bronze.ord_olist_order;
        BULK INSERT bronze.ord_olist_order
        FROM 'C:\Users\erris\OneDrive\Desktop\E-Commerce-Data-WareHouse\datasets\source_ord\olist_orders_dataset.csv'
        WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK);
        PRINT '   [SUCCESS] Orders loaded.';

        -- 8. Geolocation
        PRINT '>> Loading: bronze.ref_olist_geolocation...';
        TRUNCATE TABLE bronze.ref_olist_geolocation;
        BULK INSERT bronze.ref_olist_geolocation
        FROM 'C:\Users\erris\OneDrive\Desktop\E-Commerce-Data-WareHouse\datasets\source_ref\olist_geolocation_dataset.csv'
        WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK);
        PRINT '   [SUCCESS] Geolocation loaded.';

        -- 9. Category Translation
        PRINT '>> Loading: bronze.ref_olist_category_name_translation...';
        TRUNCATE TABLE bronze.ref_olist_category_name_translation;
        BULK INSERT bronze.ref_olist_category_name_translation
        FROM 'C:\Users\erris\OneDrive\Desktop\E-Commerce-Data-WareHouse\datasets\source_ref\product_category_name_translation.csv'
        WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK);
        PRINT '   [SUCCESS] Translations loaded.';

        PRINT '================================================';
        PRINT 'Bronze Layer Load COMPLETED Successfully.';
        PRINT '================================================';
    END TRY
    BEGIN CATCH
        PRINT '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!';
        PRINT 'ERROR OCCURRED during Bronze Load:';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!';
        -- Rollback or additional error handling can go here
    END CATCH
END
