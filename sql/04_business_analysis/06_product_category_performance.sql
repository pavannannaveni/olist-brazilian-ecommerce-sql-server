USE Ecommerce;
GO

-- Category performance for delivered orders.
-- Item rows remain at item grain; payments are not joined, so item totals
-- cannot be multiplied by multiple payment rows.
;WITH product_category AS (
    SELECT
        LTRIM(RTRIM(p.product_id)) AS product_id,
        COALESCE(
            MAX(NULLIF(LTRIM(RTRIM(ct.product_category_name_english)), '')),
            MAX(NULLIF(LTRIM(RTRIM(p.product_category_name)), '')),
            '[Uncategorized or missing product]'
        ) AS category_name
    FROM dbo.products AS p
    LEFT JOIN dbo.category_translation AS ct
        ON LTRIM(RTRIM(ct.product_category_name))
         = LTRIM(RTRIM(p.product_category_name))
    WHERE NULLIF(LTRIM(RTRIM(p.product_id)), '') IS NOT NULL
    GROUP BY LTRIM(RTRIM(p.product_id))
),
delivered_order_items AS (
    SELECT
        LTRIM(RTRIM(oi.order_id)) AS order_id,
        COALESCE(pc.category_name, '[Uncategorized or missing product]') AS category_name,
        TRY_CONVERT(
            decimal(18,2),
            NULLIF(LTRIM(RTRIM(oi.price)), '')
        ) AS merchandise_price_brl,
        TRY_CONVERT(
            decimal(18,2),
            NULLIF(LTRIM(RTRIM(oi.freight_value)), '')
        ) AS freight_value_brl
    FROM dbo.order_items AS oi
    INNER JOIN dbo.orders AS o
        ON LTRIM(RTRIM(o.order_id)) = LTRIM(RTRIM(oi.order_id))
    LEFT JOIN product_category AS pc
        ON pc.product_id = LTRIM(RTRIM(oi.product_id))
    WHERE LOWER(LTRIM(RTRIM(o.order_status))) = 'delivered'
      AND NULLIF(LTRIM(RTRIM(oi.order_id)), '') IS NOT NULL
),
category_totals AS (
    SELECT
        category_name,
        COUNT_BIG(*) AS item_count,
        COUNT(DISTINCT order_id) AS delivered_order_count,
        SUM(merchandise_price_brl) AS merchandise_value_brl,
        SUM(freight_value_brl) AS freight_value_brl,
        SUM(merchandise_price_brl + freight_value_brl)
            AS item_value_including_freight_brl
    FROM delivered_order_items
    GROUP BY category_name
)
SELECT
    category_name,
    item_count,
    delivered_order_count,
    merchandise_value_brl,
    freight_value_brl,
    item_value_including_freight_brl,
    CAST(
        100.0 * merchandise_value_brl
        / NULLIF(SUM(merchandise_value_brl) OVER (), 0)
        AS decimal(6,2)
    ) AS percent_of_merchandise_value
FROM category_totals
ORDER BY merchandise_value_brl DESC, category_name;
