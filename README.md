# Olist Brazilian E-Commerce Analysis with SQL Server

A SQL Server portfolio project exploring the public [Brazilian E-Commerce dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

## Project contents

- [Schema inventory query](sql/02_schema/01_schema_inventory.sql)
- [Product category mapping quality check](sql/03_data_quality/01_product_category_mapping_gaps.sql)
- [Monthly delivered-order analysis](sql/04_business_analysis/04_monthly_revenue_by_purchase_month.sql)
- [Repeat-purchase analysis](sql/04_business_analysis/05_repeat_purchase_analysis.sql)
- [Product-category performance analysis](sql/04_business_analysis/06_product_category_performance.sql)
- [Human-readable data dictionary](docs/data_dictionary.md)
- [Imported column metadata](docs/data_dictionary_columns.csv)

## Analyses

The monthly analysis groups delivered orders by purchase month. It aggregates item values and payment records separately by order before joining them, preventing one-to-many joins from multiplying totals. Merchandise value, freight, and recorded payment value are reported separately.

The repeat-purchase analysis counts customers using `customer_unique_id` and includes delivered orders only. The query results show 90,557 one-time buyers (97%) and 2,801 repeat buyers (3%). Repeat buyers account for 5,921 delivered orders, or an average of 2.11 delivered orders per repeat buyer. Percentages are rounded.

The product-category analysis reports delivered item counts, distinct delivered orders per category, merchandise value, freight, and each category's share of total merchandise value. The top five categories account for 39.83% of merchandise value; health and beauty is the largest at BRL 1,233,131.72 (9.33%). An order containing items from multiple categories is counted once in each relevant category's order count. The query uses the English category translation when available and falls back to the source category name.

The results also contain 1,537 item rows in the `[Uncategorized or missing product]` group, representing BRL 170,726.63 (1.29%) of merchandise value. The data-quality query separates blank product IDs, product IDs not found in the products table, and products with a blank category.

One delivered order in September 2016 has no matching payment record. The monthly analysis reports the payment total as `NULL` and counts the missing payment record instead of treating it as a zero payment.

## Data and setup

The tables are in the SQL Server database `Ecommerce`, under the `dbo` schema. Imported columns are stored as `varchar`; the analysis queries convert date and amount text as needed.

To run an analysis, open its SQL file in SQL Server Management Studio and execute it against a database loaded with the Olist tables. The dataset itself is not included in this repository.

## Data source

[Olist Brazilian E-Commerce Public Dataset on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
