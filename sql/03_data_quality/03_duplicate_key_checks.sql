/*
============================================================
Project: Brazilian E-Commerce SQL Analytics
Database: Ecommerce
Script: 03_duplicate_key_checks.sql

Purpose:
    Check candidate business keys for duplicate values.
    This is diagnostic validation; it does not add constraints
    or modify source data.

Important:
    order_items uses (order_id, order_item_id) as its
    candidate composite key.
    order_payments uses (order_id, payment_sequential).
    review_id is checked diagnostically because the source
    may contain repeated review IDs.

Author: Pavan Nannaveni
============================================================
*/

USE Ecommerce;
GO

SET NOCOUNT ON;

-- 1. Orders: order_id should identify one order.
SELECT
    'orders.order_id' AS KeyChecked,
    order_id AS DuplicateKeyValue,
    COUNT_BIG(*) AS DuplicateCount
FROM dbo.orders
GROUP BY order_id
HAVING COUNT_BIG(*) > 1

UNION ALL

-- 2. Customers: customer_id identifies a customer record.
SELECT
    'customers.customer_id',
    customer_id,
    COUNT_BIG(*)
FROM dbo.customers
GROUP BY customer_id
HAVING COUNT_BIG(*) > 1

UNION ALL

-- 3. Products: product_id should identify one product.
SELECT
    'products.product_id',
    product_id,
    COUNT_BIG(*)
FROM dbo.products
GROUP BY product_id
HAVING COUNT_BIG(*) > 1

UNION ALL

-- 4. Sellers: seller_id should identify one seller.
SELECT
    'sellers.seller_id',
    seller_id,
    COUNT_BIG(*)
FROM dbo.sellers
GROUP BY seller_id
HAVING COUNT_BIG(*) > 1

UNION ALL

-- 5. Category translation: source category name.
SELECT
    'category_translation.product_category_name',
    product_category_name,
    COUNT_BIG(*)
FROM dbo.category_translation
GROUP BY product_category_name
HAVING COUNT_BIG(*) > 1

UNION ALL

-- 6. Order items: composite candidate key.
SELECT
    'order_items(order_id, order_item_id)',
    CONCAT(order_id, ' | ', order_item_id),
    COUNT_BIG(*)
FROM dbo.order_items
GROUP BY order_id, order_item_id
HAVING COUNT_BIG(*) > 1

UNION ALL

-- 7. Payments: composite candidate key.
SELECT
    'order_payments(order_id, payment_sequential)',
    CONCAT(order_id, ' | ', payment_sequential),
    COUNT_BIG(*)
FROM dbo.order_payments
GROUP BY order_id, payment_sequential
HAVING COUNT_BIG(*) > 1

UNION ALL

-- 8. Reviews: diagnostic only; repeated review_id may occur.
SELECT
    'order_reviews.review_id (diagnostic)',
    review_id,
    COUNT_BIG(*)
FROM dbo.order_reviews
GROUP BY review_id
HAVING COUNT_BIG(*) > 1

ORDER BY KeyChecked, DuplicateCount DESC;
GO
