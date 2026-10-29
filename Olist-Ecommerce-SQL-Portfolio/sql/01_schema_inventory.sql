USE Ecommerce;
GO

SELECT
    TABLE_SCHEMA AS schema_name,
    TABLE_NAME AS table_name,
    ORDINAL_POSITION AS column_position,
    COLUMN_NAME AS column_name,
    DATA_TYPE AS sql_data_type,
    CHARACTER_MAXIMUM_LENGTH AS max_length,
    IS_NULLABLE AS is_nullable
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN (
    'category_translation',
    'customers',
    'geolocation',
    'order_items',
    'order_payments',
    'order_reviews',
    'orders',
    'products',
    'sellers'
)
ORDER BY TABLE_NAME, ORDINAL_POSITION;