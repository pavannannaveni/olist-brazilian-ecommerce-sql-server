USE Ecommerce;
GO

SELECT
    DATEFROMPARTS(
        YEAR(purchase_datetime),
        MONTH(purchase_datetime),
        1
    ) AS purchase_month,

    COUNT_BIG(*) AS delivered_order_count,
    SUM(merchandise_total) AS merchandise_value_brl,
    SUM(freight_total) AS freight_value_brl,
    SUM(payment_total) AS recorded_payment_value_brl,

    COUNT_BIG(CASE
        WHEN item_count IS NULL THEN 1
    END) AS delivered_orders_without_items,

    COUNT_BIG(CASE
        WHEN payment_record_count IS NULL THEN 1
    END) AS delivered_orders_without_payment

FROM dbo.vw_order_reporting
WHERE LOWER(LTRIM(RTRIM(order_status))) = 'delivered'
  AND purchase_datetime IS NOT NULL
GROUP BY DATEFROMPARTS(
    YEAR(purchase_datetime),
    MONTH(purchase_datetime),
    1
)
ORDER BY purchase_month;
GO
