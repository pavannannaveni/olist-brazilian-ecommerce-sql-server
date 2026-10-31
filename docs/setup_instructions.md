# Setup and Run Guide

This guide explains how to reproduce the project using the Olist CSV files and SQL Server. The database in this repository is called `Ecommerce`; the source tables are expected under the `dbo` schema.

## 1. Get the dataset

Download and unzip the [Brazilian E-Commerce Public Dataset by Olist on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). Import the nine CSV files below. Map each file to the table name used by this project:

| Olist CSV file | SQL Server table |
|---|---|
| `olist_customers_dataset.csv` | `dbo.customers` |
| `olist_geolocation_dataset.csv` | `dbo.geolocation` |
| `olist_order_items_dataset.csv` | `dbo.order_items` |
| `olist_order_payments_dataset.csv` | `dbo.order_payments` |
| `olist_order_reviews_dataset.csv` | `dbo.order_reviews` |
| `olist_orders_dataset.csv` | `dbo.orders` |
| `olist_products_dataset.csv` | `dbo.products` |
| `olist_sellers_dataset.csv` | `dbo.sellers` |
| `product_category_name_translation.csv` | `dbo.category_translation` |

The category translation CSV has a different table name in this project: import it as `category_translation`.

## 2. Create or select the database and import the files

In SQL Server Management Studio (SSMS), select the existing `Ecommerce` database. If you are setting this up on a new SQL Server instance, create a database with that name first.

Import each CSV into its mapped table using an SSMS CSV import option, such as the Import Flat File or Import and Export Data wizard. Import the first row as column names, preserve the original column names, and use CSV parsing that recognizes double quotes around text fields. This matters for review comments that may contain commas. If the import tool offers a file encoding option, choose UTF-8 so Brazilian Portuguese text is preserved.

The raw source columns in this project were imported as text (`varchar`). To match the project, keep the source columns as text and do not rename columns. In particular, preserve the source spelling `product_name_lenght`, which appears in the Olist file and is used by the clean-products view.

The source CSV files are not stored in this repository. Keep them in a separate local folder; do not upload them to GitHub. Kaggle lists the dataset license as CC BY-NC-SA 4.0, so review the dataset page's terms before redistributing the data.

## 3. Check the imported tables

Run [the schema inventory query](../sql/02_schema/01_schema_inventory.sql) in SSMS. It lists the imported tables and columns; it does not create the source tables.

Then run the checks in [`sql/03_data_quality`](../sql/03_data_quality/). The dataset should include these row counts:

| Table | Expected rows |
|---|---:|
| `orders` | 99,441 |
| `order_items` | 112,650 |
| `order_payments` | 103,886 |
| `order_reviews` | 99,224 |

Counts can help identify an incomplete import. Do not change the original source tables to fix an import; correct the import and reload the affected table if necessary.

## 4. Create the reporting views in order

Open each file in SSMS, confirm the database selector is `Ecommerce` (the files also include `USE Ecommerce;`), and execute the files in this order:

1. [Clean orders](../sql/05_views/01_clean_orders_view.sql)
2. [Clean order items](../sql/05_views/02_clean_order_items_view.sql)
3. [Clean order payments](../sql/05_views/03_clean_order_payments_view.sql)
4. [Clean order reviews](../sql/05_views/04_clean_order_reviews_view.sql)
5. [Clean products](../sql/05_views/05_clean_products_view.sql)
6. [Order-level item and payment summaries](../sql/05_views/06_order_level_totals.sql)
7. [Combined order reporting view](../sql/05_views/07_order_reporting_view.sql)

Run each file separately and wait for it to finish before opening the next one. These views leave the imported source tables unchanged. The item and payment summaries are built separately at order level before they are combined, preventing one-to-many joins from multiplying amounts.

After step 7, the validation query in that file should report 99,441 source orders, 99,441 reporting rows, and 99,441 distinct orders. It should also report 775 orders without item rows and 1 order without payment records.

## 5. Run the analyses

After creating the views, run the SQL files in [`sql/04_business_analysis`](../sql/04_business_analysis/) in SSMS. Each file is an independent analysis query; use the results to review the relevant project findings in [`results/business_insights.md`](../results/business_insights.md).

## Notes

- This project analyzes the Olist dataset's historical 2016–2018 records; results do not describe current marketplace performance.
- Merchandise value is based on item prices and excludes freight. It is not profit.
- Keep database passwords, connection strings, and other credentials out of SQL files and GitHub.
