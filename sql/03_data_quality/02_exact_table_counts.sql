/*
============================================================
Project: Brazilian E-Commerce SQL Analytics
Database: Ecommerce
Script: 02_exact_table_counts.sql

Purpose:
    Return exact row counts for the nine imported Olist tables.
    Compare these counts with the initial metadata audit.

Author: Pavan Nannaveni
============================================================
*/

USE Ecommerce;
GO

SET NOCOUNT ON;

SELECT 'category_translation' AS TableName, COUNT_BIG(*) AS ExactRowCount FROM dbo.category_translation
UNION ALL
SELECT 'customers', COUNT_BIG(*) FROM dbo.customers
UNION ALL
SELECT 'geolocation', COUNT_BIG(*) FROM dbo.geolocation
UNION ALL
SELECT 'order_items', COUNT_BIG(*) FROM dbo.order_items
UNION ALL
SELECT 'order_payments', COUNT_BIG(*) FROM dbo.order_payments
UNION ALL
SELECT 'order_reviews', COUNT_BIG(*) FROM dbo.order_reviews
UNION ALL
SELECT 'orders', COUNT_BIG(*) FROM dbo.orders
UNION ALL
SELECT 'products', COUNT_BIG(*) FROM dbo.products
UNION ALL
SELECT 'sellers', COUNT_BIG(*) FROM dbo.sellers
ORDER BY TableName;
GO
