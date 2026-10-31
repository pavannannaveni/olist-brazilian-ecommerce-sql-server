USE Ecommerce;
GO

CREATE OR ALTER VIEW dbo.vw_order_reviews_clean
AS
SELECT
    review_id,
    order_id,

    TRY_CONVERT(int,
        NULLIF(LTRIM(RTRIM(review_score)), ''))
        AS review_score,

    review_comment_title,
    review_comment_message,

    TRY_CONVERT(datetime2(0),
        NULLIF(LTRIM(RTRIM(review_creation_date)), ''), 120)
        AS review_creation_datetime,

    TRY_CONVERT(datetime2(0),
        NULLIF(LTRIM(RTRIM(review_answer_timestamp)), ''), 120)
        AS review_answer_datetime
FROM dbo.order_reviews;
GO

SELECT
    (SELECT COUNT_BIG(*) FROM dbo.order_reviews) AS source_rows,
    COUNT_BIG(*) AS view_rows,
    SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END)
        AS missing_or_invalid_scores,
    SUM(CASE WHEN review_score IS NOT NULL
                  AND (review_score < 1 OR review_score > 5)
             THEN 1 ELSE 0 END)
        AS scores_outside_1_to_5,
    SUM(CASE WHEN review_creation_datetime IS NULL THEN 1 ELSE 0 END)
        AS missing_or_invalid_creation_dates,
    SUM(CASE WHEN review_answer_datetime IS NULL THEN 1 ELSE 0 END)
        AS missing_or_invalid_answer_timestamps
FROM dbo.vw_order_reviews_clean;
GO
