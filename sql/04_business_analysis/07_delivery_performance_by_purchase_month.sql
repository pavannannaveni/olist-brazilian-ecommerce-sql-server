USE Ecommerce;
GO

-- Monthly delivery performance for orders marked delivered.
-- On-time status compares calendar dates, since the estimated delivery field
-- represents a target date. Orders without an actual or estimated date are
-- counted as unassessable and excluded from the on-time percentage denominator.
;WITH parsed_deliveries AS (
    SELECT
        LTRIM(RTRIM(order_id)) AS order_id,
        TRY_CONVERT(
            datetime2(0),
            NULLIF(LTRIM(RTRIM(order_purchase_timestamp)), ''),
            126
        ) AS purchase_datetime,
        TRY_CONVERT(
            datetime2(0),
            NULLIF(LTRIM(RTRIM(order_delivered_customer_date)), ''),
            126
        ) AS delivered_customer_datetime,
        TRY_CONVERT(
            datetime2(0),
            NULLIF(LTRIM(RTRIM(order_estimated_delivery_date)), ''),
            126
        ) AS estimated_delivery_datetime
    FROM dbo.orders
    WHERE LOWER(LTRIM(RTRIM(order_status))) = 'delivered'
),
scored_deliveries AS (
    SELECT
        CASE
            WHEN purchase_datetime IS NOT NULL
                THEN DATEFROMPARTS(YEAR(purchase_datetime), MONTH(purchase_datetime), 1)
            ELSE NULL
        END AS purchase_month,
        CASE
            WHEN delivered_customer_datetime IS NOT NULL
             AND estimated_delivery_datetime IS NOT NULL
                THEN 1
            ELSE 0
        END AS is_assessable,
        CASE
            WHEN delivered_customer_datetime IS NOT NULL
             AND estimated_delivery_datetime IS NOT NULL
             AND CONVERT(date, delivered_customer_datetime)
                 <= CONVERT(date, estimated_delivery_datetime)
                THEN 1
            ELSE 0
        END AS is_on_time,
        CASE
            WHEN purchase_datetime IS NOT NULL
             AND delivered_customer_datetime IS NOT NULL
                THEN CAST(
                    DATEDIFF(minute, purchase_datetime, delivered_customer_datetime)
                    / 1440.0
                    AS decimal(10,2)
                )
            ELSE NULL
        END AS delivery_duration_days,
        CASE
            WHEN delivered_customer_datetime IS NOT NULL
             AND estimated_delivery_datetime IS NOT NULL
                THEN DATEDIFF(
                    day,
                    CONVERT(date, estimated_delivery_datetime),
                    CONVERT(date, delivered_customer_datetime)
                )
            ELSE NULL
        END AS days_from_estimate
    FROM parsed_deliveries
)
SELECT
    purchase_month,
    COUNT_BIG(*) AS delivered_order_count,
    SUM(is_assessable) AS assessable_order_count,
    SUM(is_on_time) AS on_time_order_count,
    SUM(
        CASE
            WHEN is_assessable = 1 AND is_on_time = 0 THEN 1
            ELSE 0
        END
    ) AS late_order_count,
    SUM(
        CASE WHEN is_assessable = 0 THEN 1 ELSE 0 END
    ) AS unassessable_order_count,
    CAST(
        100.0 * SUM(is_on_time)
        / NULLIF(SUM(is_assessable), 0)
        AS decimal(5,2)
    ) AS on_time_percentage,
    CAST(AVG(delivery_duration_days) AS decimal(10,2))
        AS average_delivery_duration_days,
    CAST(AVG(CAST(days_from_estimate AS decimal(10,2))) AS decimal(10,2))
        AS average_days_from_estimate
FROM scored_deliveries
GROUP BY purchase_month
ORDER BY purchase_month;
