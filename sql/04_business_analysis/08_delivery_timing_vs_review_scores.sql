USE Ecommerce;
GO

-- Compare customer review scores for delivered orders that arrived on time
-- versus late. Reviews are aggregated to one row per order before joining,
-- so multiple review rows cannot inflate the order counts.
;WITH parsed_deliveries AS (
    SELECT
        LTRIM(RTRIM(order_id)) AS order_id,
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
delivery_outcomes AS (
    SELECT
        order_id,
        CASE
            WHEN delivered_customer_datetime IS NULL
              OR estimated_delivery_datetime IS NULL
                THEN NULL
            WHEN CONVERT(date, delivered_customer_datetime)
                 <= CONVERT(date, estimated_delivery_datetime)
                THEN 'On time or early'
            ELSE 'Late'
        END AS delivery_outcome
    FROM parsed_deliveries
    WHERE NULLIF(order_id, '') IS NOT NULL
),
review_scores_by_order AS (
    SELECT
        LTRIM(RTRIM(order_id)) AS order_id,
        AVG(
            TRY_CONVERT(
                decimal(5,2),
                NULLIF(LTRIM(RTRIM(review_score)), '')
            )
        ) AS average_review_score,
        COUNT_BIG(
            TRY_CONVERT(
                decimal(5,2),
                NULLIF(LTRIM(RTRIM(review_score)), '')
            )
        ) AS numeric_review_count
    FROM dbo.order_reviews
    WHERE NULLIF(LTRIM(RTRIM(order_id)), '') IS NOT NULL
    GROUP BY LTRIM(RTRIM(order_id))
),
assessable_orders AS (
    SELECT
        d.delivery_outcome,
        r.average_review_score,
        COALESCE(r.numeric_review_count, 0) AS numeric_review_count
    FROM delivery_outcomes AS d
    LEFT JOIN review_scores_by_order AS r
        ON r.order_id = d.order_id
    WHERE d.delivery_outcome IS NOT NULL
)
SELECT
    delivery_outcome,
    COUNT_BIG(*) AS delivered_order_count,
    SUM(
        CASE WHEN numeric_review_count > 0 THEN 1 ELSE 0 END
    ) AS orders_with_numeric_review,
    SUM(
        CASE WHEN numeric_review_count = 0 THEN 1 ELSE 0 END
    ) AS orders_without_numeric_review,
    CAST(AVG(average_review_score) AS decimal(5,2))
        AS average_review_score_per_order,
    SUM(
        CASE WHEN average_review_score <= 2 THEN 1 ELSE 0 END
    ) AS low_score_orders,
    CAST(
        100.0 * SUM(
            CASE WHEN average_review_score <= 2 THEN 1 ELSE 0 END
        )
        / NULLIF(
            SUM(CASE WHEN average_review_score IS NOT NULL THEN 1 ELSE 0 END),
            0
        )
        AS decimal(5,2)
    ) AS percent_of_reviewed_orders_scoring_2_or_lower
FROM assessable_orders
GROUP BY delivery_outcome
ORDER BY CASE WHEN delivery_outcome = 'On time or early' THEN 1 ELSE 2 END;
