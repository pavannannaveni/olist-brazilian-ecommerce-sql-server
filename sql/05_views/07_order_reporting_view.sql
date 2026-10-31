USE Ecommerce;
GO

CREATE OR ALTER VIEW dbo.vw_order_reporting
AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.purchase_datetime,
    o.approved_datetime,
    o.delivered_carrier_datetime,
    o.delivered_customer_datetime,
    o.estimated_delivery_datetime,

    i.item_count,
    i.merchandise_total,
    i.freight_total,

    p.payment_record_count,
    p.payment_total
FROM dbo.vw_orders_clean AS o
LEFT JOIN dbo.vw_order_item_totals_by_order AS i
    ON o.order_id = i.order_id
LEFT JOIN dbo.vw_order_payment_totals_by_order AS p
    ON o.order_id = p.order_id;
GO

SELECT
    (SELECT COUNT_BIG(*) FROM dbo.orders) AS source_order_rows,
    COUNT_BIG(*) AS report_rows,
    COUNT_BIG(DISTINCT order_id) AS distinct_orders,
    SUM(CASE WHEN item_count IS NULL THEN 1 ELSE 0 END)
        AS orders_without_item_rows,
    SUM(CASE WHEN payment_record_count IS NULL THEN 1 ELSE 0 END)
        AS orders_without_payment_records
FROM dbo.vw_order_reporting;
GO
