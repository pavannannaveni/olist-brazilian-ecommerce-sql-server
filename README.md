# Olist Brazilian E-Commerce Analysis with SQL Server

A SQL Server portfolio project using the public [Brazilian E-Commerce dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

## Project contents

- [Schema inventory query](Olist-Ecommerce-SQL-Portfolio/sql/01_schema_inventory.sql)
- [Monthly delivered-order analysis](Olist-Ecommerce-SQL-Portfolio/sql/04_monthly_revenue_by_purchase_month.sql)
- [SQL column metadata](Olist-Ecommerce-SQL-Portfolio/docs/data_dictionary_columns.csv)

## Current analysis

The monthly query groups delivered orders by purchase month. It calculates merchandise value and freight from order items, and recorded payment value from payment records. Each is aggregated by order before joining to avoid multiplying totals.

One delivered order in September 2016 has no matching payment record. The analysis reports the payment total as `NULL` and counts the missing record instead of treating it as a zero payment.

## Data and setup

The tables are in the SQL Server database `Ecommerce`, under the `dbo` schema. Imported columns are stored as `varchar`; the analysis query converts dates and amounts when needed.

To run the analysis, open the SQL file in SQL Server Management Studio and execute it against a database loaded with the Olist tables. The dataset itself is not included in this repository.

## Data source

[Olist Brazilian E-Commerce Public Dataset on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
