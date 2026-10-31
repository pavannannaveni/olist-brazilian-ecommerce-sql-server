USE Ecommerce;
GO

-- Aggregate item rows to one row per order before joining other order-level data.
CREATE OR ALTER VIEW dbo.vw_order_item_totals_by_order
AS
SELECT
    order_id,
    COUNT_BIG(*) AS item_count,
    SUM(price) AS merchandise_total,
    SUM(freight_value) AS freight_total
FROM dbo.vw_order_items_clean
GROUP BY order_id;
GO

-- Aggregate payment rows separately to one row per order.
CREATE OR ALTER VIEW dbo.vw_order_payment_totals_by_order
AS
SELECT
    order_id,
    COUNT_BIG(*) AS payment_record_count,
    SUM(payment_amount) AS payment_total
FROM dbo.vw_order_payments_clean
GROUP BY order_id;
GO

SELECT
    (SELECT COUNT_BIG(*) FROM dbo.orders) AS source_order_rows,
    (SELECT COUNT_BIG(*) FROM dbo.vw_order_item_totals_by_order)
        AS orders_with_items,
    (SELECT SUM(item_count) FROM dbo.vw_order_item_totals_by_order)
        AS item_rows_reconciled,
    (SELECT COUNT_BIG(*) FROM dbo.vw_order_payment_totals_by_order)
        AS orders_with_payment_records,
    (SELECT SUM(payment_record_count) FROM dbo.vw_order_payment_totals_by_order)
        AS payment_rows_reconciled;
GO
