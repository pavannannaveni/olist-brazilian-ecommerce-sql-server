USE Ecommerce;
GO

-- Separates month-over-month merchandise changes into:
-- 1. Order-volume effect, using the previous month's average
-- 2. Average-order-value effect, using the current month's order count
-- Merchandise value excludes freight.

;WITH monthly_sales AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(purchase_datetime),
            MONTH(purchase_datetime),
            1
        ) AS purchase_month,
        COUNT_BIG(*) AS delivered_order_count,
        SUM(CAST(COALESCE(merchandise_total, 0) AS decimal(19, 2)))
            AS merchandise_value_brl,
        AVG(CAST(COALESCE(merchandise_total, 0) AS decimal(19, 6)))
            AS average_merchandise_per_order_brl
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
        delivered_order_count,
        merchandise_value_brl,
        average_merchandise_per_order_brl,
        LAG(purchase_month) OVER (
            ORDER BY purchase_month
        ) AS previous_available_month,
        LAG(delivered_order_count) OVER (
            ORDER BY purchase_month
        ) AS previous_available_order_count,
        LAG(merchandise_value_brl) OVER (
            ORDER BY purchase_month
        ) AS previous_available_merchandise_brl,
        LAG(average_merchandise_per_order_brl) OVER (
            ORDER BY purchase_month
        ) AS previous_available_average_brl
    FROM monthly_sales
),
calendar_comparison AS
(
    SELECT
        *,
        CASE
            WHEN previous_available_month = DATEADD(MONTH, -1, purchase_month)
            THEN previous_available_order_count
        END AS previous_calendar_month_order_count,
        CASE
            WHEN previous_available_month = DATEADD(MONTH, -1, purchase_month)
            THEN previous_available_merchandise_brl
        END AS previous_calendar_month_merchandise_brl,
        CASE
            WHEN previous_available_month = DATEADD(MONTH, -1, purchase_month)
            THEN previous_available_average_brl
        END AS previous_calendar_month_average_brl
    FROM monthly_with_lag
)
SELECT
    purchase_month,
    delivered_order_count,
    merchandise_value_brl,
    CAST(average_merchandise_per_order_brl AS decimal(19, 2))
        AS average_merchandise_per_order_brl,
    previous_available_month,
    previous_calendar_month_order_count,
    previous_calendar_month_merchandise_brl,
    CAST(previous_calendar_month_average_brl AS decimal(19, 2))
        AS previous_calendar_month_average_brl,

    CASE
        WHEN previous_calendar_month_order_count IS NOT NULL
        THEN delivered_order_count - previous_calendar_month_order_count
    END AS order_count_change,

    CASE
        WHEN previous_calendar_month_order_count IS NOT NULL
        THEN merchandise_value_brl - previous_calendar_month_merchandise_brl
    END AS merchandise_change_brl,

    CAST(
        CASE
            WHEN previous_calendar_month_order_count IS NOT NULL
            THEN
                (
                    CAST(delivered_order_count AS decimal(19, 6))
                    - CAST(previous_calendar_month_order_count AS decimal(19, 6))
                ) * previous_calendar_month_average_brl
        END
        AS decimal(19, 2)
    ) AS order_volume_effect_brl,

    CAST(
        CASE
            WHEN previous_calendar_month_order_count IS NOT NULL
            THEN
                CAST(delivered_order_count AS decimal(19, 6))
                * (
                    average_merchandise_per_order_brl
                    - previous_calendar_month_average_brl
                )
        END
        AS decimal(19, 2)
    ) AS average_order_value_effect_brl
FROM calendar_comparison
ORDER BY purchase_month;
GO
