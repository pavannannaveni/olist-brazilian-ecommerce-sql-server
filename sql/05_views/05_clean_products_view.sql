USE Ecommerce;
GO

CREATE OR ALTER VIEW dbo.vw_products_clean
AS
SELECT
    product_id,
    product_category_name,

    TRY_CONVERT(int,
        NULLIF(LTRIM(RTRIM(product_name_lenght)), ''))
        AS product_name_length,

    TRY_CONVERT(int,
        NULLIF(LTRIM(RTRIM(product_description_lenght)), ''))
        AS product_description_length,

    TRY_CONVERT(int,
        NULLIF(LTRIM(RTRIM(product_photos_qty)), ''))
        AS product_photos_quantity,

    TRY_CONVERT(int,
        NULLIF(LTRIM(RTRIM(product_weight_g)), ''))
        AS product_weight_g,

    TRY_CONVERT(int,
        NULLIF(LTRIM(RTRIM(product_length_cm)), ''))
        AS product_length_cm,

    TRY_CONVERT(int,
        NULLIF(LTRIM(RTRIM(product_height_cm)), ''))
        AS product_height_cm,

    TRY_CONVERT(int,
        NULLIF(LTRIM(RTRIM(product_width_cm)), ''))
        AS product_width_cm
FROM dbo.products;
GO

;WITH product_numeric_values AS
(
    SELECT NULLIF(LTRIM(RTRIM(values_to_check.raw_value)), '')
        AS raw_value
    FROM dbo.products AS p
    CROSS APPLY (VALUES
        (p.product_name_lenght),
        (p.product_description_lenght),
        (p.product_photos_qty),
        (p.product_weight_g),
        (p.product_length_cm),
        (p.product_height_cm),
        (p.product_width_cm)
    ) AS values_to_check(raw_value)
)
SELECT
    (SELECT COUNT_BIG(*) FROM dbo.products) AS source_rows,
    (SELECT COUNT_BIG(*) FROM dbo.vw_products_clean) AS view_rows,
    SUM(CASE WHEN raw_value IS NULL THEN 1 ELSE 0 END)
        AS blank_numeric_attributes,
    SUM(CASE
        WHEN raw_value IS NOT NULL AND TRY_CONVERT(int, raw_value) IS NULL
        THEN 1 ELSE 0
    END) AS invalid_nonblank_numeric_attributes
FROM product_numeric_values;
GO
