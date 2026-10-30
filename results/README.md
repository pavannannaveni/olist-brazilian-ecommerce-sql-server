# Results

This folder contains selected outputs from the Olist SQL analysis.

## Monthly merchandise value

The chart shows merchandise value for delivered orders, grouped by purchase month. It uses item prices; freight and recorded payment totals are excluded. It is based on [04_monthly_revenue_by_purchase_month.sql](../sql/04_business_analysis/04_monthly_revenue_by_purchase_month.sql). The line is broken across November 2016 because that month has no row in the shared query output.

![Monthly merchandise value](monthly_merchandise_sales.svg)

## Monthly on-time delivery rate

The chart shows the monthly share of delivered orders arriving on or before the estimated delivery date, grouped by purchase month. It is based on [07_delivery_performance_by_purchase_month.sql](../sql/04_business_analysis/07_delivery_performance_by_purchase_month.sql). The first month has only one delivered order, so interpret its 0% rate cautiously.

![Monthly on-time delivery rate](monthly_on_time_delivery.png)
