![image](https://github.com/user-attachments/assets/8b035d12-dba4-4782-8ef2-7d329e455de7)


# Case Study Context

This modules challenges follow a case study for an ELT pipeline. The dataset that you will be using is from the French company Greenweez. Greenweez is an organic e-commerce website that caters to B2C customers by offering a variety of products for a healthier and more sustainable lifestyle.

In these challenges you assume the role of a Data/Analytics Engineer working on a project with the finance team.

The finance team has requested the creation of a comprehensive table in BigQuery for conducting basket analysis. The table should encompass the following key metrics:

- **Daily Transaction Evolution:** Tracking the number of transactions (orders) that occur each day.
- **Daily Average Basket Evolution:** Monitoring the average basket amount for each day.
- **Daily Margin and Operational Margin Evolution**: Observing the evolution of both margin and operational margin on a daily basis.

In order to fulfill their requirements, they have specified the need for a well-structured data pipeline that adheres to the following principles:

#### Data Accuracy and Protection:

The pipeline should be designed to prevent the insertion of incorrect or erroneous data into the production environment, ensuring data accuracy and integrity.

#### Error Identification and Handling:

The pipeline should have mechanisms in place to break down complexity, making it easy to identify and handle any new errors that may arise without disrupting access to data.

#### Organized and Accessible Structure:

The mart layer data should be organized and stored in a separate dataset from the raw and intermediate data to prevent any potential misunderstandings regarding its structure or usage within the finance team.

#### Comprehensive Documentation:

Provide detailed and comprehensive documentation of the table, including its columns, and lineage to understand where the data are coming from to enhance understanding and usage.

The DBT pipeline should effectively cater to these requirements, ensuring the finance team has access to up-to-date and accurate information for their daily dashboard needs.

## A reminder of the data

A reminder on the tables in the raw, source data that we'll be using in the next few challenges:
- **raw_gz_sales** - Timestamped sales with order_id, product_id, revenue, quantity
- **raw_gz_product** - product_id, purchSE_PRICE
- **raw_gz_ship** - Logistics data with fees and costs

# 1️- Setup Big Query and Raw Data

## 1.1. Download the Raw Data

The data that we'll be using is from Greenweez. There will be more context on the case study in the next challenge. We'll start with three tables to start with. Manually downloading them to your VM then uploading to BigQuery.
- **raw_gz_sales** - Timestamped sales with order_id, product_id, revenue, quantity
- **raw_gz_product** - product_id, purchSE_PRICE
- **raw_gz_ship** - Logistics data with fees and costs

To download the data and save to the `data/` folder run the following commands:

```bash
# Create the folder
mkdir -p data/

# Download the data
curl -o ./data/raw_gz_sales.parquet https://wagon-public-datasets.s3.amazonaws.com/data-engineering/gz_raw_data-raw_gz_sales.parquet
curl -o ./data/raw_gz_product.parquet https://wagon-public-datasets.s3.amazonaws.com/data-engineering/gz_raw_data-raw_gz_product.parquet
curl -o ./data/raw_gz_ship.parquet https://wagon-public-datasets.s3.amazonaws.com/data-engineering/gz_raw_data-raw_gz_ship.parquet
```

<details>
<summary markdown='span'>💡 Peak at the data</summary>
See below for the first three rows of the data in each table and a description of each field.

---

Sales Table

| date_date  | orders_id | pdt_id | revenue | quantity |
|------------|-----------|--------|---------|----------|
| 2021-04-01 | 825408    | 29372  | 1.92    | 2        |
| 2021-04-01 | 825408    | 119246 | 12.07   | 1        |
| 2021-04-01 | 825409    | 88694  | 2.94    | 1        |

Fields:
- `date_date` - order date
- `orders_id` - order identifier - foreign key to ship table
- `pdt_id` - product identifier - foreign key to product table
- `revenue` - price paid by customer to purchase the products
- `quantity` - quantity of a product purchased in an order

---

Product Table

| products_id | purchSE_PRICE |
|-------------|---------------|
| 95325       | 0             |
| 5547        | 2             |
| 5652        | 2             |

Fields:
- `products_id` - product identifier - primary key
- `purchSE_PRICE` - cost for Greenweez to obtain a single unit of the product

---

Ship Table

| orders_id | shipping_fee | shipping_fee_1 | logCost | ship_cost |
|-----------|--------------|----------------|---------|-----------|
| 1002259   | 3.54         | 3.54           | 8.0     | 2         |
| 1001464   | 20.0         | 20.0           | 10.25   | 2         |
| 997252    | 0.82         | 0.82           | 12.05   | 2         |

Fields:
- `orders_id` - order identifier - primary key
- `shipping_fee` - fee customer pays for a shipping an order
- `shipping_fee_1` - fee customer pays for shipping an order
- `logCost` - Greenweez cost to preparing the parcel for delivery
- `ship_cost` - Greenweez shipping cost paid to logistics provider to deliver order

</details>

## 1.2. Create BigQuery Dataset

We will need to create a dataset in BigQuery to hold our raw data for DBT to source from.

Either:
- Open the [BigQuery console](https://console.cloud.google.com/bigquery) and create a dataset called `raw_gz_data` located in the `EU (multiple regions in the European Union)`
- Use the `bq` command line utility to create a new dataset

<details>
<summary markdown='span'>🎁 bq create dataset</summary>

```bash
# bq mk --location=EU --dataset <project_id>:<dataset_id>
bq mk --location=EU --dataset <your_gcp_project_id>:raw_gz_data
```
</details>

## 1.3. Upload Data to BigQuery

Once the dataset has been created, upload the data you have saved locally in the `data/` folder.

Either:
- Use the [BigQuery console](https://console.cloud.google.com/bigquery) to create a new table and upload the data from file.
- Use the `bq` command line utility to upload each parquet file.

Make sure that the table names are:
- `raw_gz_sales`
- `raw_gz_product`
- `raw_gz_ship`

<details>
<summary markdown='span'>🎁 bq bulk load</summary>

```bash
bq load --autodetect \
    --source_format=PARQUET \
    --location=EU \
    raw_gz_data.<your_table_name> \
    ./path/to/data.parquet
```
</details>

To confirm that the data has been uploaded, head to the GCP console and have a look at the schema and preview for each table.

<br>

# 2️- Install DBT

There are multiple versions of DBT, which vary depending on the database system you're interacting with. We'll be using DBT with BigQuery.

- In your terminal, run `pip install dbt-bigquery`.

Make sure DBT is installed by executing `dbt --version` in your terminal.

# 3️- Initialize the DBT project

## 3.1. Initialize `dbt_bigquery_project` directory

DBT works by creating a DBT project directory inside your project. This directory is where all our models, SQL files, and (most) configuration files will be. We'll call our DBT project: **dbt_bigquery_project**

Do not worry if you make an error during this process, you can modify any field afterwards.

- In your terminal, run `dbt init`.
- When prompted:
  - **Enter a name for your project (letters, digits, underscore):** Enter `dbt_bigquery_project`
  - **Which database would you like to use? Enter a number:** Enter `1` (for `bigquery`)
  - **Desired authentication method option (enter a number):** Enter `2` (for `service_account`)
  - **keyfile (/path/to/bigquery/keyfile.json):** Enter the **absolute** path of where you stored your BigQuery service account key
  - **project (GCP project id):** Enter your GCP Project ID that you created
  - **dataset (the name of your dbt dataset):** Enter the dataset name that you created
  - **threads (1 or more):** Enter `2`
  - **job_execution_timeout_seconds [300]:** Enter `300`
  - **Desired location option (enter a number):** Enter `2` for `EU`
 
## 3.2. Verify the setup of `profiles.yml`

DBT Core works on the concepts of **profiles**. Typically for each DBT project you would have one **profile**, and generally one **profile** for each business unit or team that you work with.

Each **profile** can contain one or more *targets*. Each *target* defines what data warehouse you are using, authentication credentials, output dataset name, and data location. With different *targets* we can apply the same pipeline to read from different source datasets and write to different output datasets. It's how we differentiate between development and production.

Let's check that the `profiles.yml` file is configured correctly:
- By default, your DBT profile will be stored in your VM's **home directory** at `~/.dbt/profiles.yml`
 
## 3.3. Verify `dbt_project.yml` file

_No action item in this section - we're just providing context._

Open the `dbt_bigquery_project` folder, and open the `dbt_project.yml` file in this folder:
- Verify that the project name (~line 5) is correct: `name: 'dbt_bigquery_project'`
- Verify that the profile name (~line 10) is correct: `profile: 'dbt_bigquery_project'`
- At the bottom of the file, make sure the `models` parameter refers to your project name:

```yml
models:
  dbt_lewagon: # <-- should match the `name` tag
  # Config indicated by + and applies to all files under models/example/
  example:
    +materialized: view
```

Delete the folders and files within the models folder.

# 4️- Enhance DBT project tree

### 4.1. Organising DBT Models

Let's organize our project a bit. We'll be working with four layers, similar to a bronze, silver, gold architecture with an extra layer for sourcing:
- `source` data - where we'll source our data from
- `staging` data - a cleaner version of the `source` data, with some casting and column renaming
- `intermediate` data - where we'll perform aggregations and transformations
- `mart` data - which contains clean metrics that business stakeholders can report on.

Let's make sure the `.sql` and `.yaml` files corresponding to each layer are in a corresponding folder. `cd` to the `dbt_lewagon` directory. From there, execute the following command:

```bash
mkdir models/source;
mkdir models/staging;
mkdir models/intermediate;
mkdir -p models/mart/finance;
```

We built the above structure (`source`, `staging`, `intermediate`, and `mart` folders) for a specific reason. When we organise our models in directories, our tables/views in BigQuery will be prefixed to make them more identifiable. We want `.sql` models:
- In our `staging` directory to create schemas in BigQuery that are prefixed with `stg_`
- In our `intermediate` directory to create schemas prefixed with `int_`
- In our `mart/finance` directory to create schemas to serve the finance team

In our `source` folder, we will only have a configuration file: `sources.yaml`. We don't need SQL models for this because we'll read directly from tables in our raw dataset, `raw_gz_data`, on BigQuery.

# 5️- Configuring Sources

We have our raw data loaded and our DBT project initialized, let's start with configuring the data sources, where DBT is retrieving our data, and what our models will work with.

- Under the `models/source` folder, create a file named `sources.yml`. This is where you'll configure the reference to the source BigQuery dataset.
- Populate this file so that DBT understands:
    - Which BigQuery dataset the source data is in
    - Which tables in this dataset we are reading from
    - Have a look at the source properties documentation at [this link](https://docs.getdbt.com/reference/source-properties) for more details on how to configure a source in DBT.
- Configure 1 source dataset:
    - `raw_gz_data`
- Configure 3 source tables:
    - `raw_gz_sales`
    - `raw_gz_product`
    - `raw_gz_ship`

# 6- Configuring staging models

- Configuring your first **staging model** that reads from `gz_raw_sales`
- Under the `models/staging/` folder, create a file called `stg_gz_sales.sql`.
- Configure the model with the following:
    - It should be materialized as a **view**
    - Keep all the columns
    - Rename the column: `pdt_id` to `products_id`

Now that you have a working model for your `sales` source. Generate two additional **staging models** for both the `product` and `ship` sources with the following requirements:

Product:
- Name the model: stg_gz_product.sql
- Materialize as a **view**
- Rename `purCHASE_PRICE` to `purchase_price` and cast to `FLOAT64`
- Keep all the columns

Ship:
- Name the model: stg_gz_ship.sql
- Materialize as a **view**
- Check the difference between `shipping_fee` and `shipping_fee_1`. You can use the BigQuery console to execute exploration queries. Use a `WHERE` clause and an inequality operator to determine the difference between the two columns.
- Rename `logCost` to `log_cost`
- Cast `ship_cost` to an appropriate data type.

When you think you have your models running, execute them individually with:

```bash
dbt run -m stg_gz_product
dbt run -m stg_gz_ship
```

Or run all your models with:

```bash
dbt run
```

If everything runs with no problems, have a look on BigQuery to check that the tables have been created! 

## 7- Source Documentation

Let's start by adding some documentation to our sources.

❓ Add a description about the schema (BigQuery dataset), **every table**, and **every column** in the `sources.yml` file.

## 8- Source Tests

DBT comes with some built in tests for things like uniqueness of values in a column and making sure that there are no null values in a column.

- Create a `__stg_schema.yml` file within the staging folder
- Add some generic tests to `__stg_schema.yml`

## 9- Create Intermediate Models

Our goal is to create an intermediate layer that builds on the previously created **staging models**.

## 9.1. Margin per Product

The first intermediate model you will create is `int_sales_margin.sql`. It will log information about the purchase cost and margin made on **each product**.

Under the `models/intermediate/` directory, create a file called `int_sales_margin.sql`. Configure the model with the following requirements:
- Materialize the model as a **view** - think about why this model should be a view vs table.
- The output view should have the following fields:
    - `products_id`: product identifier
    - `orders_id`: order identifier
    - `date_date`: order date
    - `revenue`: price paid by customer to purchase the products
    - `quantity`: quantity of a product purchased in an order
    - `purchase_price`: Greenweez cost to obtain a single unit of the product
    - `purchase_cost`: Greenweez cost to obtain the products in an order
    - `margin`: Profit Greenweez makes on the sale of different products
- Round float values to two decimal places.
- Order by `orders_id` so that more recent orders appear first.

Metric definitions:
- `purchase_cost` = `quantity` * `purchase_price`
- `margin` = `revenue` - `purchase_cost`

## 9.2. Margin per Order

The second intermediate model you will create is `int_orders_margin.sql`. It will log information about the purchase cost and margin made on **each order**.

Under the `models/intermediate/` directory, create a file called `int_orders_margin.sql`. Configure the model with the following requirements:
- Materialize the model as a **view**
- The output view should have the following fields:
    - `orders_id`: order identifier
    - `date_date`: order date
    - `revenue`: price paid by customer to purchase all products in an order
    - `quantity`: quantity of products in an order
    - `purchase_cost`: Greenweez cost to obtain the products in an order
    - `margin`: profit Greenweez makes on the sale of products in an order
- Round float values to two decimal places.
- Order by `orders_id` so that more recent orders appear first.

## 1.3. Operational Margin per Order

The last intermediate model we will create is `int_orders_operational`. This model will capture information about the cost of shipping and logistics.

Under the `models/intermediate/` directory, create a file called `int_orders_operational.sql`. Configure the model with the following requirements:
- Materialize the model as a **view**
- The output view should have the following fields:
    - `orders_id`: order identifier
    - `date_date`: order date
    - `operational_margin`: profit Greenweez makes on the sale of products in an order after operational and logistics costs
    - `quantity`: quantity of products in an order
    - `revenue`: price paid by customer to purchase all products in an order
    - `purchase_cost`: Greenweez cost to obtain the products in an order
    - `margin`: profit Greenweez makes on the sale of products in an order, not accounting for operational and logistics costs
    - `shipping_fee`: fee customer pays for shipping an order
    - `log_cost`: Greenweez cost to prepare the parcel for delivery
    - `ship_cost`: Greenweez shipping cost paid to logistics provider to deliver order
- Round float values to two decimal places.
- Order by `orders_id` so that more recent orders appear first.

Metric definitions:
- `operational_margin` = ( `margin` + `shipping_fee` ) - ( `log_cost` + `ship_cost` )

# 10- Mart Model

Mart models create tables or views designed to serve other stakeholders in your business. In this case study, it will be the finance team. Because these other stakeholders may not be as technical as you, the goal is to have the majority of data available for the stakeholders to use with simple `SELECT` queries - within reason.

The finance team has sent across their data requirements, it's time to create a mart model that suits their needs.

## 10.1. Finance mart model

The mart model we will create is `finance_days`. This model will serve data for the finance team at a **daily granularity**.

Under the `models/mart/finance/` directory, create a file called `finance_days.sql`. Configure the model with the following requirements:
- Materialize the model as a **view** - Again, think if this model should materialize as a **view** or **table**. For now, materialize as a view.
- The output view should have the following fields:
    - `date_date`: date
    - `nb_transactions`: daily number of orders
    - `quantity`: daily quantity of all products sold
    - `revenue`: daily price paid by customers for all products sold
    - `average_basket`: daily average order revenue
    - `margin`: daily profit Greenweez makes on orders
    - `operational_margin`: daily profit Greenweez makes on an orders after operational and logistics costs
    - `purchase_cost`: daily Greenweez cost to obtain the products sold
    - `shipping_fee`: daily total price paid by all customers for shipping
    - `log_cost`: daily Greenweez cost to prepare parcels for delivery
    - `ship_cost`: daily Greenweez cost paid to logistics providers to deliver orders
- Round all float values to two decimal places.
- Order by `date_date` so that the data appears in reverse chronological order.

# 12- Create a margin_percent macro

- In the `macros/` directory, create a `functions.sql` file.
- Using [DBT's documentation at this link](https://docs.getdbt.com/docs/build/jinja-macros#macros) on Jinja macros, define the macro: `margin_percent` with the following parameters:
    - The macro should take the columns `revenue` and `purchase_cost` as inputs
    - Define what the macro should return: `margin_percent` = `margin` / `revenue`
    - Round the result to two decimal places, but provide an option for the user to control how many decimal places so show.

When you think you have a working macro, edit your `int_sales_margin.sql` model to add a column with `margin_percent`.


