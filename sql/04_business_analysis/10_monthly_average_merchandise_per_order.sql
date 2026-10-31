USE Ecommerce;
GO

;WITH monthly_orders AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(purchase_datetime),
            MONTH(purchase_datetime),
            1
        ) AS purchase_month,

        COUNT_BIG(*) AS delivered_order_count,

        COUNT_BIG(CASE
            WHEN item_count IS NOT NULL THEN 1
        END) AS delivered_orders_with_items,

        COUNT_BIG(CASE
            WHEN item_count IS NULL THEN 1
        END) AS delivered_orders_without_items,

        SUM(merchandise_total) AS merchandise_value_brl
    FROM dbo.vw_order_reporting
    WHERE LOWER(LTRIM(RTRIM(order_status))) = 'delivered'
      AND purchase_datetime IS NOT NULL
    GROUP BY DATEFROMPARTS(
        YEAR(purchase_datetime),
        MONTH(purchase_datetime),
        1
    )
)
SELECT
    purchase_month,
    delivered_order_count,
    delivered_orders_with_items,
    delivered_orders_without_items,
    merchandise_value_brl,

    CAST(
        merchandise_value_brl / NULLIF(delivered_order_count, 0)
        AS decimal(18,2)
    ) AS avg_merchandise_per_delivered_order_brl,

    CAST(
        merchandise_value_brl / NULLIF(delivered_orders_with_items, 0)
        AS decimal(18,2)
    ) AS avg_merchandise_per_order_with_items_brl
FROM monthly_orders
ORDER BY purchase_month;
GO
