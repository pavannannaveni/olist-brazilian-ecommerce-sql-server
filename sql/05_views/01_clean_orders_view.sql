USE Ecommerce;
GO

CREATE OR ALTER VIEW dbo.vw_orders_clean
AS
SELECT
    order_id,
    customer_id,
    order_status,

    TRY_CONVERT(datetime2(0),
        NULLIF(LTRIM(RTRIM(order_purchase_timestamp)), ''), 120)
        AS purchase_datetime,

    TRY_CONVERT(datetime2(0),
        NULLIF(LTRIM(RTRIM(order_approved_at)), ''), 120)
        AS approved_datetime,

    TRY_CONVERT(datetime2(0),
        NULLIF(LTRIM(RTRIM(order_delivered_carrier_date)), ''), 120)
        AS delivered_carrier_datetime,

    TRY_CONVERT(datetime2(0),
        NULLIF(LTRIM(RTRIM(order_delivered_customer_date)), ''), 120)
        AS delivered_customer_datetime,

    TRY_CONVERT(datetime2(0),
        NULLIF(LTRIM(RTRIM(order_estimated_delivery_date)), ''), 120)
        AS estimated_delivery_datetime
FROM dbo.orders;
GO

SELECT
    COUNT_BIG(*) AS total_orders,
    SUM(CASE
        WHEN NULLIF(LTRIM(RTRIM(o.order_purchase_timestamp)), '') IS NOT NULL
             AND v.purchase_datetime IS NULL
        THEN 1 ELSE 0
    END) AS invalid_purchase_dates
FROM dbo.orders AS o
INNER JOIN dbo.vw_orders_clean AS v
    ON v.order_id = o.order_id;
GO
