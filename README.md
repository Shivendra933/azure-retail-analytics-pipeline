# azure-retail-analytics-pipeline
This end-to-end retail analytics platform on Azure uses ADF to orchestrate batch and streaming data through a Databricks Medallion architecture. Data from sources like Event Hubs is processed using Delta Lake, with features like PII masking, and served in Snowflake for visualization in Power BI.

# End-to-End Retail Analytics Platform on Azure

## Project Goal

Retail companies often struggle with integrating data from siloed systems like in-store Point-of-Sale (POS), e-commerce websites, and inventory management. This project solves that problem by building a unified, scalable, and secure data platform. The key objectives were to automate data ingestion, ensure data quality through a Medallion Architecture, provide real-time alerts for fraud and low inventory, and deliver curated insights to business users via interactive dashboards.

## Architecture

The platform is built on a modern Lakehouse architecture, processing data through Bronze, Silver, and Gold layers. ADF and Event Hub handle ingestion, Databricks manages all transformations, and Snowflake serves as the final, high-performance warehouse for BI consumption.

<img width="959" height="745" alt="Architecture Diagram" src="https://github.com/user-attachments/assets/6072bb67-f139-4380-aba1-6bb5e10a6522" />


## Tech Stack

* **Orchestration:** Azure Data Factory (ADF)
* **Data Lake:** Azure Data Lake Storage (ADLS) Gen2
* **Real-Time Ingestion:** Azure Event Hubs
* **Transformation Engine:** Azure Databricks, Apache Spark (PySpark)
* **Data Format:** Delta Lake
* **Data Warehouse:** Snowflake
* **Business Intelligence:** Power BI
* **Security:** Azure Service Principal, PII Masking
* **Languages:** Python, SQL, DAX

## Codebase Overview

This repository contains the five key Databricks notebooks that power the entire pipeline.

### `Bronze Ingestion.ipynb`
* **Purpose:** This notebook is called by Azure Data Factory to ingest raw source files.
* **Logic:** It accepts parameters (`source_filename`, `bronze_table_name`), reads a raw CSV file from the `raw` container, and writes it as a Delta table to the `bronze` container in ADLS. It uses a `DROP TABLE` and `.option("path", ...)` strategy to ensure tables are correctly located.

### `Silver_Gold_Transformations.ipynb`
* **Purpose:** The main batch processing engine for the Medallion Architecture.
* **Logic:**
    * **Silver Layer:** Reads all Bronze tables, applies PII masking to customer data, cleanses data types, and enriches the data by joining 5 separate tables into a single `silver_fact_orders` table. It resolves 5 column name conflicts during this join.
    * **Gold Layer:** Reads the Silver tables and creates 7 pre-aggregated, BI-ready tables (e.g., `gold_daily_sales_summary`, `gold_monthly_product_sales`).
    * **Inventory Snapshot:** Creates the initial `gold_current_inventory` table from the daily snapshot, which is later updated by the streaming pipeline.

### `event-producer.ipynb`
* **Purpose:** Simulates a live feed of real-time data.
* **Logic:** Reads the `stream_events.ndjson` file from ADLS and publishes each line (2,160 total events) as a message to an Azure Event Hub, ready for the consumer to process.

### `streaming-consumer.ipynb`
* **Purpose:** The real-time processing engine that runs continuously.
* **Logic:**
    * Connects to the Azure Event Hub, configuring the `startingPosition` to read all available data.
    * **Fraud Stream:** Filters for `order_created` events, applies a fraud detection rule (`OrderValue > 1000`), and writes alerts to the `gold_fraud_alerts` table.
    * **Inventory Stream:** Filters for `inventory_update` events, pre-aggregates each micro-batch to prevent errors, and uses a Delta Lake `MERGE INTO` command to update the `gold_current_inventory` table in near-real-time.

### `snowflake-loading.ipynb`
* **Purpose:** The final step of the batch pipeline, loading the curated data into the warehouse.
* **Logic:** Connects to both ADLS (using the Service Principal) and Snowflake. It then reads all 12 Silver and Gold Delta tables and writes them to the `RETAIL_DW.ANALYTICS` schema in Snowflake, making them available for Power BI.
