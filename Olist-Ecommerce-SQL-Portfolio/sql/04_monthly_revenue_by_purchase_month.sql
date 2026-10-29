USE Ecommerce;
GO

;WITH item_totals AS (
    SELECT
        LTRIM(RTRIM(order_id)) AS order_id,
        SUM(TRY_CONVERT(decimal(18,2), LTRIM(RTRIM(price)))) AS merchandise_value,
        SUM(TRY_CONVERT(decimal(18,2), LTRIM(RTRIM(freight_value)))) AS freight_value
    FROM dbo.order_items
    GROUP BY LTRIM(RTRIM(order_id))
),
payment_totals AS (
    SELECT
        LTRIM(RTRIM(order_id)) AS order_id,
        SUM(TRY_CONVERT(decimal(18,2), LTRIM(RTRIM(payment_value)))) AS recorded_payment_value
    FROM dbo.order_payments
    GROUP BY LTRIM(RTRIM(order_id))
),
delivered_orders AS (
    SELECT
        LTRIM(RTRIM(order_id)) AS order_id,
        TRY_CONVERT(datetime2(0), LTRIM(RTRIM(order_purchase_timestamp)), 126) AS purchase_datetime
    FROM dbo.orders
    WHERE LOWER(LTRIM(RTRIM(order_status))) = 'delivered'
)
SELECT
    DATEFROMPARTS(YEAR(d.purchase_datetime), MONTH(d.purchase_datetime), 1) AS purchase_month,
    COUNT_BIG(*) AS delivered_order_count,
    SUM(i.merchandise_value) AS merchandise_value_brl,
    SUM(i.freight_value) AS freight_value_brl,
    SUM(p.recorded_payment_value) AS recorded_payment_value_brl,
    COUNT_BIG(CASE WHEN i.order_id IS NULL THEN 1 END) AS delivered_orders_without_items,
    COUNT_BIG(CASE WHEN p.order_id IS NULL THEN 1 END) AS delivered_orders_without_payment
FROM delivered_orders AS d
LEFT JOIN item_totals AS i
    ON i.order_id = d.order_id
LEFT JOIN payment_totals AS p
    ON p.order_id = d.order_id
WHERE d.purchase_datetime IS NOT NULL
GROUP BY DATEFROMPARTS(YEAR(d.purchase_datetime), MONTH(d.purchase_datetime), 1)
ORDER BY purchase_month;