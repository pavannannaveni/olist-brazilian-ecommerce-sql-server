USE Ecommerce;
GO

;WITH customer_order_counts AS (
    SELECT
        LTRIM(RTRIM(c.customer_unique_id)) AS customer_unique_id,
        COUNT(DISTINCT LTRIM(RTRIM(o.order_id))) AS delivered_order_count
    FROM dbo.orders AS o
    INNER JOIN dbo.customers AS c
        ON LTRIM(RTRIM(c.customer_id)) = LTRIM(RTRIM(o.customer_id))
    WHERE LOWER(LTRIM(RTRIM(o.order_status))) = 'delivered'
      AND NULLIF(LTRIM(RTRIM(c.customer_unique_id)), '') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(o.order_id)), '') IS NOT NULL
    GROUP BY LTRIM(RTRIM(c.customer_unique_id))
),
segmented_customers AS (
    SELECT
        CASE
            WHEN delivered_order_count = 1 THEN 'One-time buyer'
            ELSE 'Repeat buyer'
        END AS customer_type,
        delivered_order_count
    FROM customer_order_counts
),
summary AS (
    SELECT
        customer_type,
        COUNT_BIG(*) AS customer_count,
        SUM(delivered_order_count) AS total_delivered_orders,
        AVG(CAST(delivered_order_count AS decimal(10,2)))
            AS average_orders_per_customer
    FROM segmented_customers
    GROUP BY customer_type
)
SELECT
    customer_type,
    customer_count,
    CAST(
        100.0 * customer_count / NULLIF(SUM(customer_count) OVER (), 0)
        AS decimal(5,2)
    ) AS customer_percentage,
    total_delivered_orders,
    CAST(average_orders_per_customer AS decimal(10,2))
        AS average_orders_per_customer
FROM summary
ORDER BY CASE WHEN customer_type = 'One-time buyer' THEN 1 ELSE 2 END;