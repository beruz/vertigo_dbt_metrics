# Vertigo Games – Task 2: DBT Data Model & Looker Studio BI Dashboard

---

## Purpose

This piece demonstrates how you would:
* Build a robust, testable **daily metrics table** to calculate key KPIs like DAU, ARPDAU, win ratios, and more.  
* Feed that model into Looker Studio to create a clear dashboard for stakeholders.

---

## Data Pipeline

**Raw data:**  
- Stored in **BigQuery** (e.g., dataset: `events`, table: `user_metrics`).  
- Data comes from daily user activity CSVs.

**DBT project:**  
- Cleans, standardizes, and aggregates this raw data.  
- Uses a layered approach:
  - **Daily metrics view:** Summarizes daily KPIs by `event_date`, `country`, and `platform`.
  - **Incremental table:** Stores daily metrics partitioned by `event_date` and uses incremental for cost efficiency with daily inserts and faster refreshes. Every field is defined in SELECT statement instead of using ```SELECT *``` because in the future new metric fields can be added and the model needs to be updated in order to prevent any incremental load failure.

---

## DBT Models

**Structure:**
models/\
├── marts/\
│ ├── daily_metrics_v.sql\
│ └── daily_metrics.sql\
│ └── schema.yml

## Assumptions 

Before modeling, I have analyzed the data and took action for an cost-efficent, optimized performance and clean models.

* **Data corrections:** I assumed that raw CSVs may have missing or malformed data — so casting numeric columns safely and using SAFE_DIVIDE ensures no division-by-zero errors in KPIs.
* **Partitioning:** BigQuery’s costs can increase fast with daily data, so the incremental table is partitioned by event_date and only overwrites partitions when needed.

## Looker Studio BI Dashboard

The Looker Studio dashboard was created by directly connecting the ```daily_metrics``` table inBigQuery with these core principles:
- **Rolling 7-day logic:** Smooths daily spikes and highlights weekly patterns, which are especially relevant in mobile gaming.
- **Fixed date range:** Because the data covers only one month and is static, the date range is fixed. In production, the rolling windows would adapt automatically as new data arrives.
- **Scorecards:** Display the latest rolling 7-day values for DAU, ARPDAU, Total Revenue, Win Ratio, Matches per DAU, and Server Errors per DAU — each with percentage change vs. the previous period.
- **Trend charts:** A dual-axis line shows how DAU and ARPDAU move together or diverge. Another chart splits In-App Purchases and Ads revenue streams.
- **Heatmap:** Visualizes server errors by country to catch region-specific infra issues.
- **Breakdowns:** Pie charts show Matches by Country and In-App Purchases by Country to help spot top-performing regions.
