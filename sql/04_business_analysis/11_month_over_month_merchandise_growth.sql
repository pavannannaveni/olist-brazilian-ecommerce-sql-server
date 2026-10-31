USE Ecommerce;
GO

-- Month-over-month change in merchandise value for delivered orders.
-- Merchandise value is based on item prices and excludes freight.
-- If a calendar month has no rows, growth metrics are returned as NULL
-- instead of comparing with an older, non-consecutive month.

;WITH monthly_sales AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(purchase_datetime),
            MONTH(purchase_datetime),
            1
        ) AS purchase_month,
        SUM(merchandise_total) AS merchandise_value_brl
    FROM dbo.vw_order_reporting
    WHERE LOWER(LTRIM(RTRIM(order_status))) = 'delivered'
      AND purchase_datetime IS NOT NULL
    GROUP BY DATEFROMPARTS(
        YEAR(purchase_datetime),
        MONTH(purchase_datetime),
        1
    )
),
monthly_with_lag AS
(
    SELECT
        purchase_month,
        merchandise_value_brl,
        LAG(purchase_month) OVER (
            ORDER BY purchase_month
        ) AS previous_available_month,
        LAG(merchandise_value_brl) OVER (
            ORDER BY purchase_month
        ) AS previous_available_merchandise_brl
    FROM monthly_sales
)
SELECT
    purchase_month,
    merchandise_value_brl,
    previous_available_month,

    CASE
        WHEN previous_available_month = DATEADD(MONTH, -1, purchase_month)
        THEN previous_available_merchandise_brl
    END AS previous_calendar_month_merchandise_brl,

    CASE
        WHEN previous_available_month = DATEADD(MONTH, -1, purchase_month)
        THEN merchandise_value_brl - previous_available_merchandise_brl
    END AS mom_change_brl,

    CAST(
        CASE
            WHEN previous_available_month = DATEADD(MONTH, -1, purchase_month)
            THEN
                (merchandise_value_brl - previous_available_merchandise_brl)
                * 100.0
                / NULLIF(previous_available_merchandise_brl, 0)
        END
        AS decimal(10, 2)
    ) AS mom_change_pct
FROM monthly_with_lag
ORDER BY purchase_month;
GO
