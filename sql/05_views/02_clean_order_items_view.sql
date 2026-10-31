USE Ecommerce;
GO

CREATE OR ALTER VIEW dbo.vw_order_items_clean
AS
SELECT
    order_id,
    order_item_id,

    TRY_CONVERT(int,
        NULLIF(LTRIM(RTRIM(order_item_id)), ''))
        AS order_item_number,

    product_id,
    seller_id,

    TRY_CONVERT(datetime2(0),
        NULLIF(LTRIM(RTRIM(shipping_limit_date)), ''), 120)
        AS shipping_limit_datetime,

    TRY_CONVERT(decimal(12,2),
        NULLIF(LTRIM(RTRIM(price)), ''))
        AS price,

    TRY_CONVERT(decimal(12,2),
        NULLIF(LTRIM(RTRIM(freight_value)), ''))
        AS freight_value
FROM dbo.order_items;
GO

SELECT
    (SELECT COUNT_BIG(*) FROM dbo.order_items) AS source_rows,
    COUNT_BIG(*) AS view_rows,
    SUM(CASE WHEN order_item_number IS NULL THEN 1 ELSE 0 END)
        AS missing_or_invalid_item_numbers,
    SUM(CASE WHEN shipping_limit_datetime IS NULL THEN 1 ELSE 0 END)
        AS missing_or_invalid_shipping_dates,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END)
        AS missing_or_invalid_prices,
    SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END)
        AS missing_or_invalid_freight_values
FROM dbo.vw_order_items_clean;
GO
