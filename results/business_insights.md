# Business Insights

## Executive summary

This project analyzes Olist's public Brazilian e-commerce orders using SQL Server. The findings describe delivered orders, merchandise value, customer repeat behavior, product categories, delivery performance, and reviews. Merchandise value is the sum of item prices and excludes freight; it is not profit because product costs and operating expenses are not included.

The analysis retains order-level reporting and aggregates item and payment records separately before combining them. This avoids multiplying totals when joining one-to-many detail tables.

## Key findings

### Sales and order value

- The data covers purchase activity from September 2016 through August 2018. November 2016 has no delivered-order month in the analysis, so month-over-month comparisons skip that month.
- Monthly merchandise value peaked at BRL 987,765.37 in November 2017.
- Average merchandise per delivered order ranged from BRL 124.38 in July 2017 to BRL 152.17 in October 2016.
- In October 2016, delivered orders increased from 1 to 265. The merchandise increase was BRL 40,190.14; the decomposition attributes BRL 35,632.08 to order volume and BRL 4,558.06 to average order value.
- In January 2017, delivered orders increased from 1 to 750. The merchandise increase was BRL 111,787.46; the decomposition attributes BRL 8,164.10 to order volume and BRL 103,623.36 to average order value. December 2016 had only one delivered order, so this average-order-value effect reflects a very small baseline.

### Customers

- The repeat-purchase analysis found 90,557 one-time buyers (97%) and 2,801 repeat buyers (3%), using customer_unique_id and delivered orders.
- Repeat buyers accounted for 5,921 delivered orders, an average of 2.11 delivered orders per repeat buyer.

### Product categories

- The five largest categories represented 39.83% of delivered merchandise value.
- Health and beauty was the largest category at BRL 1,233,131.72, or 9.33% of merchandise value.
- The analysis identified 1,537 delivered item rows with a blank product category. They accounted for BRL 170,726.63 in merchandise value (1.29%) and BRL 26,969.06 in freight across 1,392 delivered orders.

### Payment methods

- The analysis covers all 103,886 recorded payment rows, totaling BRL 16,008,872.12.
- Credit card payments totaled BRL 12,542,084.19 (78.34%); boleto payments totaled BRL 2,869,361.27 (17.92%).
- Credit card records averaged 3.51 installments, and 51,338 records (66.85%) had more than one installment.
- An order can have payment records under multiple methods, so method-level order counts overlap. These figures describe recorded payment values and are not limited to delivered orders.

### Sellers

- The analysis ranks the top 25 sellers with at least 20 delivered orders, using merchandise value from delivered items.
- The highest-ranked eligible seller, in Guariba, São Paulo state, had 1,124 delivered orders, 1,148 delivered items, BRL 226,987.93 in merchandise value, and BRL 20,019.13 in freight. Average merchandise value per seller order was BRL 201.95.
- An order containing items from multiple sellers is counted once for each participating seller. These results describe attributed sales volume; they do not measure seller profit.

### Delivery and reviews

- Of 96,478 delivered orders, 96,470 had the dates needed to assess delivery timing. Of those assessable orders, 89,936 (93.23%) arrived on or before the estimated calendar date.
- March 2018 had the lowest monthly on-time rate, 81.04%, with 1,328 late orders.
- The average review score was 4.29 for assessable orders delivered on time or early and 2.27 for late orders.
- Reviews with an average score of 2 or lower represented 9.23% of reviewed on-time or early orders and 62.36% of reviewed late orders. This is a descriptive association; it does not establish that late delivery caused lower reviews.

## Data quality and interpretation notes

- The source tables were imported with text fields stored as varchar; the clean views convert relevant dates and numeric values for analysis.
- The analysis found 99,441 orders, 112,650 order-item rows, and 103,886 payment rows. Item and payment details are summarized separately at order level before joining.
- One delivered order in September 2016 had no matching payment record. Its missing payment total is reported as NULL, not as a zero payment.
- November 2016 has no delivered-order month in the monthly results. Its absence is not treated as zero sales when calculating month-over-month changes.
- The decomposition defines the order-volume effect using the previous month's average merchandise per order, then calculates the average-order-value effect using the current month's order count. Displayed amounts are rounded to cents and can differ from the total change by BRL 0.01.
- One seller-city value appeared in SSMS as “santa barbara dÂ´oeste,” which is consistent with a text-encoding mismatch. Confirm the source file encoding before re-importing; the city label does not affect the numeric seller results.
- Findings are descriptive of this public dataset and period. They should not be interpreted as causal effects or as current marketplace performance.

## Related project files

- [Monthly merchandise sales chart](monthly_merchandise_sales.svg)
- [Monthly on-time delivery chart](monthly_on_time_delivery.png)
- [SQL analyses](../sql/04_business_analysis/)
- [Project README](../README.md)
- [Olist dataset source](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
