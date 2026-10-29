# Olist Data Dictionary

This document describes the tables and columns in the Olist Brazilian E-Commerce dataset used by this project.

The data is stored in the SQL Server database `Ecommerce`, under the `dbo` schema. The imported columns are `varchar`; convert date and numeric text to suitable SQL types when analyzing them. See `data_dictionary_columns.csv` for the imported SQL column types and lengths.

## `category_translation`

Maps Portuguese product category names to English names.

| Column | Meaning |
|---|---|
| `product_category_name` | Category name in Portuguese; used by the products table. |
| `product_category_name_english` | English translation of the category name. |

## `customers`

Contains customer records and location details.

| Column | Meaning |
|---|---|
| `customer_id` | Customer record identifier referenced by orders. |
| `customer_unique_id` | Identifier for the customer across orders; use this for repeat-customer analysis. |
| `customer_zip_code_prefix` | Customer postal-code prefix. |
| `customer_city` | Customer city. |
| `customer_state` | Customer state abbreviation. |

## `geolocation`

Contains geographic coordinates and place names associated with postal-code prefixes. A prefix may have multiple rows, so summarize or deduplicate this table before joining it to sales data.

| Column | Meaning |
|---|---|
| `geolocation_zip_code_prefix` | Postal-code prefix. |
| `geolocation_lat` | Latitude. |
| `geolocation_lng` | Longitude. |
| `geolocation_city` | City associated with the location. |
| `geolocation_state` | State abbreviation. |

## `orders`

One row per order in the supplied dataset.

| Column | Meaning |
|---|---|
| `order_id` | Order identifier. |
| `customer_id` | Customer record that placed the order. |
| `order_status` | Current recorded status of the order. |
| `order_purchase_timestamp` | Date and time the customer placed the order. |
| `order_approved_at` | Date and time the order was approved, when available. |
| `order_delivered_carrier_date` | Date and time the order was handed to the carrier, when available. |
| `order_delivered_customer_date` | Date and time the order was delivered, when available. |
| `order_estimated_delivery_date` | Estimated delivery date. |

## `order_items`

Contains the products included in each order. An order can contain multiple item rows.

| Column | Meaning |
|---|---|
| `order_id` | Order containing the item. |
| `order_item_id` | Item sequence number within the order. |
| `product_id` | Product identifier. |
| `seller_id` | Seller identifier. |
| `shipping_limit_date` | Seller shipping deadline for the item. |
| `price` | Item merchandise price in Brazilian reais (BRL). |
| `freight_value` | Freight amount for the item in BRL. |

## `order_payments`

Contains payment records. An order can have multiple payment rows.

| Column | Meaning |
|---|---|
| `order_id` | Order associated with the payment. |
| `payment_sequential` | Sequence number of the payment within the order. |
| `payment_type` | Payment method. |
| `payment_installments` | Number of payment installments. |
| `payment_value` | Amount recorded for the payment in BRL. |

## `order_reviews`

Contains customer review details associated with orders.

| Column | Meaning |
|---|---|
| `review_id` | Review identifier. |
| `order_id` | Order associated with the review. |
| `review_score` | Customer rating recorded for the review. |
| `review_comment_title` | Optional review title. |
| `review_comment_message` | Optional review text. |
| `review_creation_date` | Date the review was created. |
| `review_answer_timestamp` | Date and time the review was answered, when available. |

## `products`

Contains product attributes.

| Column | Meaning |
|---|---|
| `product_id` | Product identifier. |
| `product_category_name` | Product category name in Portuguese, when available. |
| `product_name_lenght` | Product name length; the source column uses this spelling. |
| `product_description_lenght` | Product description length; the source column uses this spelling. |
| `product_photos_qty` | Number of product photos. |
| `product_weight_g` | Product weight in grams. |
| `product_length_cm` | Product length in centimeters. |
| `product_height_cm` | Product height in centimeters. |
| `product_width_cm` | Product width in centimeters. |

## `sellers`

Contains seller identifiers and location details.

| Column | Meaning |
|---|---|
| `seller_id` | Seller identifier. |
| `seller_zip_code_prefix` | Seller postal-code prefix. |
| `seller_city` | Seller city. |
| `seller_state` | Seller state abbreviation. |

## Relationship and analysis notes

- Join `orders.customer_id` to `customers.customer_id`.
- Join `order_items.order_id`, `order_payments.order_id`, and `order_reviews.order_id` to `orders.order_id`.
- Join `order_items.product_id` to `products.product_id` and `order_items.seller_id` to `sellers.seller_id`.
- Join `products.product_category_name` to `category_translation.product_category_name` for English category names.
- `customer_unique_id` is the appropriate customer identifier for counting people or repeat purchases.
- `price` is merchandise value and `freight_value` is shipping cost. Payment totals are recorded separately in `order_payments`.
- Orders, items, payments, and reviews can have one-to-many relationships. Aggregate each detail table to the intended level before joining, so totals are not multiplied.
