USE Ecommerce;
GO

-- Summarizes all recorded payment rows by payment method.
-- An order can have more than one payment row or payment method.

;WITH payment_rows AS
(
    SELECT
        order_id,
        COALESCE(
            NULLIF(LOWER(LTRIM(RTRIM(payment_type))), ''),
            '[unknown]'
        ) AS payment_type,
        installment_count,
        payment_amount
    FROM dbo.vw_order_payments_clean
),
method_summary AS
(
    SELECT
        payment_type,
        COUNT_BIG(*) AS payment_record_count,
        COUNT_BIG(payment_amount) AS valid_amount_record_count,
        COUNT(DISTINCT order_id) AS orders_with_method,
        SUM(payment_amount) AS recorded_payment_value_brl,
        AVG(payment_amount) AS average_payment_record_brl,
        AVG(CAST(installment_count AS decimal(10, 2))) AS average_installments,
        COUNT_BIG(CASE WHEN installment_count > 1 THEN 1 END)
            AS multi_installment_record_count,
        COUNT_BIG(installment_count) AS valid_installment_record_count
    FROM payment_rows
    GROUP BY payment_type
)
SELECT
    payment_type,
    payment_record_count,
    valid_amount_record_count,
    orders_with_method,
    recorded_payment_value_brl,
    CAST(
        100.0 * recorded_payment_value_brl
        / NULLIF(SUM(recorded_payment_value_brl) OVER (), 0)
        AS decimal(7, 2)
    ) AS payment_value_share_pct,
    CAST(average_payment_record_brl AS decimal(19, 2))
        AS average_payment_record_brl,
    CAST(average_installments AS decimal(10, 2))
        AS average_installments,
    multi_installment_record_count,
    CAST(
        100.0 * multi_installment_record_count
        / NULLIF(valid_installment_record_count, 0)
        AS decimal(7, 2)
    ) AS multi_installment_record_pct
FROM method_summary
ORDER BY recorded_payment_value_brl DESC;
GO
