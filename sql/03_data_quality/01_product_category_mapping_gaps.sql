USE Ecommerce;
GO

-- Investigate delivered items labeled "[Uncategorized or missing product]"
-- by the product-category analysis.
;WITH product_lookup AS (
    SELECT
        LTRIM(RTRIM(product_id)) AS product_id,
        MAX(NULLIF(LTRIM(RTRIM(product_category_name)), '')) AS source_category_name
    FROM dbo.products
    WHERE NULLIF(LTRIM(RTRIM(product_id)), '') IS NOT NULL
    GROUP BY LTRIM(RTRIM(product_id))
),
delivered_items AS (
    SELECT
        LTRIM(RTRIM(oi.order_id)) AS order_id,
        NULLIF(LTRIM(RTRIM(oi.product_id)), '') AS product_id,
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
    WHERE LOWER(LTRIM(RTRIM(o.order_status))) = 'delivered'
),
classified_items AS (
    SELECT
        di.order_id,
        CASE
            WHEN di.product_id IS NULL
                THEN 'Order item has a blank product_id'
            WHEN pl.product_id IS NULL
                THEN 'product_id not found in products'
            WHEN pl.source_category_name IS NULL
                THEN 'Product has a blank category'
            ELSE 'Product has a category'
        END AS mapping_status,
        di.merchandise_price_brl,
        di.freight_value_brl
    FROM delivered_items AS di
    LEFT JOIN product_lookup AS pl
        ON pl.product_id = di.product_id
)
SELECT
    mapping_status,
    COUNT_BIG(*) AS item_count,
    COUNT(DISTINCT order_id) AS delivered_order_count,
    SUM(merchandise_price_brl) AS merchandise_value_brl,
    SUM(freight_value_brl) AS freight_value_brl
FROM classified_items
WHERE mapping_status <> 'Product has a category'
GROUP BY mapping_status
ORDER BY item_count DESC, mapping_status;
