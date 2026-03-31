/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'E-Commerce DataWarehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'E-Commerce DataWarehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/


USE master;
GO


-- Drop and recreate the 'E-Commerce DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'E-Commerce DataWarehouse')
BEGIN
	ALTER DATABASE [E-Commerce DataWarehouse] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [E-Commerce DataWarehouse];
END;
GO

-- Create Database 'E-Commerce DataWarehouse'
CREATE DATABASE [E-Commerce DataWarehouse];
GO

USE [E-Commerce DataWarehouse];
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
