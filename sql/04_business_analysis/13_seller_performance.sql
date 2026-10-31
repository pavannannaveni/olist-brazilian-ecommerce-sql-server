USE Ecommerce;
GO

-- Ranks sellers by merchandise value from delivered orders.
-- Includes sellers with at least 20 delivered orders to avoid
-- ranking sellers with very little activity.
-- Merchandise value excludes freight and is not profit.

SELECT TOP (25)
    i.seller_id,
    COALESCE(NULLIF(LTRIM(RTRIM(s.seller_city)), ''), '[Unknown]')
        AS seller_city,
    COALESCE(NULLIF(LTRIM(RTRIM(s.seller_state)), ''), '[Unknown]')
        AS seller_state,
    COUNT(DISTINCT i.order_id) AS delivered_order_count,
    COUNT_BIG(*) AS delivered_item_count,
    SUM(COALESCE(i.price, 0)) AS merchandise_value_brl,
    SUM(COALESCE(i.freight_value, 0)) AS freight_value_brl,
    CAST(
        SUM(COALESCE(i.price, 0))
        / NULLIF(CAST(COUNT(DISTINCT i.order_id) AS decimal(19, 4)), 0)
        AS decimal(19, 2)
    ) AS average_merchandise_per_seller_order_brl
FROM dbo.vw_order_items_clean AS i
INNER JOIN dbo.vw_orders_clean AS o
    ON i.order_id = o.order_id
LEFT JOIN dbo.sellers AS s
    ON i.seller_id = s.seller_id
WHERE LOWER(LTRIM(RTRIM(o.order_status))) = 'delivered'
GROUP BY
    i.seller_id,
    COALESCE(NULLIF(LTRIM(RTRIM(s.seller_city)), ''), '[Unknown]'),
    COALESCE(NULLIF(LTRIM(RTRIM(s.seller_state)), ''), '[Unknown]')
HAVING COUNT(DISTINCT i.order_id) >= 20
ORDER BY
    merchandise_value_brl DESC,
    delivered_order_count DESC,
    i.seller_id;
GO
