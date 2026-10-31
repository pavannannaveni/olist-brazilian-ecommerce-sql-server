USE Ecommerce;
GO

CREATE OR ALTER VIEW dbo.vw_order_payments_clean
AS
SELECT
    order_id,
    payment_type,

    TRY_CONVERT(int,
        NULLIF(LTRIM(RTRIM(payment_sequential)), ''))
        AS payment_sequence_number,

    TRY_CONVERT(int,
        NULLIF(LTRIM(RTRIM(payment_installments)), ''))
        AS installment_count,

    TRY_CONVERT(decimal(12,2),
        NULLIF(LTRIM(RTRIM(payment_value)), ''))
        AS payment_amount
FROM dbo.order_payments;
GO

SELECT
    (SELECT COUNT_BIG(*) FROM dbo.order_payments) AS source_rows,
    COUNT_BIG(*) AS view_rows,
    SUM(CASE WHEN payment_sequence_number IS NULL THEN 1 ELSE 0 END)
        AS missing_or_invalid_payment_sequences,
    SUM(CASE WHEN installment_count IS NULL THEN 1 ELSE 0 END)
        AS missing_or_invalid_installment_counts,
    SUM(CASE WHEN payment_amount IS NULL THEN 1 ELSE 0 END)
        AS missing_or_invalid_payment_values
FROM dbo.vw_order_payments_clean;
GO
