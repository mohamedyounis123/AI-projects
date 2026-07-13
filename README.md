# Airbnb European Cities — Medallion Architecture Data Warehouse

An end-to-end Data Engineering portfolio project that transforms raw Airbnb
listing data from European cities into a fully structured, analytics-ready
Data Warehouse, built following the **Medallion Architecture** pattern
(Bronze → Silver → Gold), with a Power BI dashboard as the final analytical
layer.

## Project Overview

This project ingests raw Airbnb pricing data for 10 major European cities
(Amsterdam, Athens, Barcelona, Berlin, Budapest, Lisbon, London, Paris,
Rome, Vienna — plus Cairo included as an additional comparison point),
progressively cleans and enriches it, and delivers it as a relational
**Star Schema** data warehouse in Microsoft SQL Server, visualized through
an interactive Power BI dashboard.

The goal is to demonstrate a complete, production-style data pipeline —
not just an analysis notebook — covering data validation, data quality
rules, feature engineering, dimensional modeling, and BI reporting.

## Architecture

```
raw_source/                  Original raw CSV (input only, untouched)
        │
        ▼
1_bronze_layer/               Raw ingestion — no cleaning, schema validation only
        │
        ▼
2_silver_layer/               Cleaning, standardization, feature engineering,
        │                     data quality rules, data quality report
        ▼
3_gold_layer/                 Star Schema (Fact + Dimension tables) in SQL Server
        │
        ▼
4_powerbi_dashboard/           Interactive Power BI report (build guide included)

other_scripts/                Web scraping (Selenium) + exploratory analysis
```

## Layer Details

### 1. Bronze Layer (`1_bronze_layer/`)
Loads the raw CSV file exactly as-is, with **no transformation**. Its only
responsibilities are archiving a raw snapshot and validating the incoming
schema (row/column counts, null counts, duplicate rows, city name
consistency), logging a full validation report for traceability.

- `scripts/ingest_raw_data.py` — full ingestion + validation script
- `data/raw/` — archived raw snapshot
- `logs/` — ingestion run logs

### 2. Silver Layer (`2_silver_layer/`)
Takes the Bronze output and produces a clean, enriched **master dataset**:
- Schema validation (fails fast on missing required columns)
- Data type coercion (numeric columns forced to proper types)
- Text cleaning and city-name standardization (e.g. `Roma` → `Rome`)
- Missing-value indicator flags (before any row is dropped)
- Data quality rules (removes logically invalid rows — e.g. price ≤ 0)
- Feature engineering: `price_per_bedroom`, `price_per_guest`,
  `price_per_person`, `listing_quality_score`, `host_score`,
  `price_category`, `is_weekend`, and more
- Pipeline metadata columns (`silver_processed_time`, `source_system`)
- A surrogate key (`record_id`) for use as the Gold layer's primary key

- `scripts/build_silver_dataset.py` — full cleaning + feature engineering pipeline
- `data/cleaned/airbnb_master_dataset.csv` — final master dataset
- `reports/silver_quality_report.csv` — before/after data quality metrics

### 3. Gold Layer (`3_gold_layer/`)
Models the Silver master dataset into a **Star Schema**, implemented in
Microsoft SQL Server:

- **Fact table:** `fact_listings` — one row per listing, with all metrics
  and engineered features
- **Dimension tables:** `dim_location`, `dim_room_type`, `dim_day_type`,
  `dim_price_category`

```
                dim_location
                     │
dim_room_type ── fact_listings ── dim_day_type
                     │
              dim_price_category
```

- `sql/create_star_schema_sqlserver.sql` — DDL: table definitions,
  primary/foreign keys, indexes
- `scripts/build_gold_layer_sqlserver.py` — ETL script: builds dimension
  tables, joins the fact table, and loads everything into SQL Server

### 4. Power BI Dashboard (`4_powerbi_dashboard/`)
An interactive, multi-page dashboard connected directly to the Gold layer
SQL Server database:

- **Executive Overview** — high-level KPI indicators with targets
- **Overview** — dynamic titles, city comparison, room type split
- **City & Price Analysis** — price category breakdown, Top 10 / Bottom 10 cities
- **Room Type Analysis** — professional scatter plot (price vs. satisfaction,
  sized by bedrooms, colored by Superhost status)
- **Host Analysis** — Superhost vs. standard host comparison
- **Location Analysis** — geographic drill-down hierarchy (Country → City → District)
- **Map & Details** — interactive map with custom tooltips and drill-through pages

Additional professional features: custom page-navigation buttons, Key
Influencers visual, Decomposition Tree, Smart Narrative, synced slicers,
and a custom Airbnb-inspired color theme.

- `POWERBI_BUILD_GUIDE.md` — complete step-by-step build instructions
  (every page, visual, DAX measure, and formatting decision documented)

### 5. Other Scripts (`other_scripts/`)
- `scraping/` — a Selenium-based web scraper designed to enrich the
  dataset with live features from Airbnb.com (price, rating, review count,
  Superhost / Guest Favorite status) for listings matching specific filters
  (Entire home/apt, 2+ bedrooms), city by city
- `eda/` — exploratory data analysis notebooks/queries

## How to Run the Full Pipeline

```bash
# 1. Bronze layer
cd 1_bronze_layer/scripts
python ingest_raw_data.py

# 2. Silver layer
cd ../../2_silver_layer/scripts
python build_silver_dataset.py

# 3. Gold layer (requires SQL Server + pyodbc)
cd ../../3_gold_layer/scripts
python build_gold_layer_sqlserver.py

# 4. Power BI dashboard
# Open Power BI Desktop → connect to the AirbnbDWH SQL Server database
# → follow 4_powerbi_dashboard/POWERBI_BUILD_GUIDE.md
```

Each layer reads its input from the previous layer's output — run them in
order.

## Tech Stack

- **Python** (pandas) — data ingestion, cleaning, and feature engineering
- **Selenium** — web scraping for feature enrichment
- **Microsoft SQL Server** (T-SQL, pyodbc) — dimensional data warehouse
- **Power BI** — interactive reporting and dashboards

## Known Data Limitations

- The current dataset contains only `weekday` listings — no `weekend` data
  is present in the source, so weekday/weekend price comparisons are not
  currently possible. The schema (`dim_day_type`) was intentionally kept
  to support this comparison if weekend data is added later.
- `Cairo` is included as an additional city for comparison purposes and is
  not part of the original "Airbnb Prices in European Cities" dataset.

## License

This project is for educational and portfolio purposes.