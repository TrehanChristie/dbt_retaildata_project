Case Study Context
This challenge follows a case study for an ELT pipeline. The dataset that you will be using is from the French company Greenweez. Greenweez is an organic e-commerce website that caters to B2C customers by offering a variety of products for a healthier and more sustainable lifestyle.

In these challenges you assume the role of a Data/Analytics Engineer working on a project with the finance team.

The finance team has requested the creation of a comprehensive table in BigQuery for conducting basket analysis. The table should encompass the following key metrics:

Daily Transaction Evolution: Tracking the number of transactions (orders) that occur each day.
Daily Average Basket Evolution: Monitoring the average basket amount for each day.
Daily Margin and Operational Margin Evolution: Observing the evolution of both margin and operational margin on a daily basis.
In order to fulfill their requirements, they have specified the need for a well-structured data pipeline that adheres to the following principles:

Data Accuracy and Protection:
The pipeline should be designed to prevent the insertion of incorrect or erroneous data into the production environment, ensuring data accuracy and integrity.

Error Identification and Handling:
The pipeline should have mechanisms in place to break down complexity, making it easy to identify and handle any new errors that may arise without disrupting access to data.

Organized and Accessible Structure:
The mart layer data should be organized and stored in a separate dataset from the raw and intermediate data to prevent any potential misunderstandings regarding its structure or usage within the finance team.

Comprehensive Documentation:
Provide detailed and comprehensive documentation of the table, including its columns, and lineage to understand where the data are coming from to enhance understanding and usage.

The DBT pipeline should effectively cater to these requirements, ensuring the finance team has access to up-to-date and accurate information for their daily dashboard needs.

A reminder of the data
A reminder on the tables in the raw, source data that we’ll be using in the next few challenges:

raw_gz_sales - Timestamped sales with order_id, product_id, revenue, quantity
raw_gz_product - product_id, purchSE_PRICE
raw_gz_ship - Logistics data with fees and costs

1️⃣Setup Big Query and Raw Data
1.1. Download the Raw Data
The data that we’ll be using is from Greenweez. There will be more context on the case study in the next challenge. We’ll start with three tables to start with. Manually downloading them to your VM then uploading to BigQuery.

raw_gz_sales - Timestamped sales with order_id, product_id, revenue, quantity
raw_gz_product - product_id, purchSE_PRICE
raw_gz_ship - Logistics data with fees and costs
To download the data and save to the data/ folder run the following commands:

# Create the folder
mkdir -p data/

# Download the data
curl -o ./data/raw_gz_sales.parquet https://wagon-public-datasets.s3.amazonaws.com/data-engineering/gz_raw_data-raw_gz_sales.parquet
curl -o ./data/raw_gz_product.parquet https://wagon-public-datasets.s3.amazonaws.com/data-engineering/gz_raw_data-raw_gz_product.parquet
curl -o ./data/raw_gz_ship.parquet https://wagon-public-datasets.s3.amazonaws.com/data-engineering/gz_raw_data-raw_gz_ship.parquet

1.2. Create BigQuery Dataset
We will need to create a dataset in BigQuery to hold our raw data for DBT to source from.

Either:

Open the BigQuery console and create a dataset called raw_gz_data located in the EU (multiple regions in the European Union)
Use the bq command line utility to create a new dataset

1.3. Upload Data to BigQuery
Once the dataset has been created, upload the data you have saved locally in the data/ folder.

Either:

Use the BigQuery console to create a new table and upload the data from file.
Use the bq command line utility to upload each parquet file.
Make sure that the table names are:

raw_gz_sales
raw_gz_product
raw_gz_ship

2️⃣ Install DBT
2.1. Install DBT for bigquery. In your terminal, run pip install dbt-bigquery.

3️⃣ Initialize the DBT project
3.1. Initialize dbt_lewagon directory
DBT works by creating a DBT project directory inside your project. This directory is where all our models, SQL files, and (most) configuration files will be. We’ll call our DBT project: dbt_lewagon

Do not worry if you make an error during this process, you can modify any field afterwards.

In your terminal, go to the 01-Setup-DBT challenge root. This is where we’ll create the DBT project.
In your terminal, run dbt init.
When prompted:
Enter a name for your project (letters, digits, underscore): Enter dbt_lewagon. If prompted: The profile dbt_lewagon already exists in ~/.dbt/profiles.yml. Continue and overwrite it? Hit N.
Which database would you like to use? Enter a number: Enter 1 (for bigquery)
Desired authentication method option (enter a number): Enter 2 (for service_account)
keyfile (/path/to/bigquery/keyfile.json): Enter the absolute path of where you stored your BigQuery service account key that you created during the Data Engineering setup, including the file name and extension. It should look similar to: /home/username/.gcp_keys/le-wagon-de-bootcamp.json.
project (GCP project id): Enter your GCP Project ID that you created during the Data Engineering setup
dataset (the name of your dbt dataset): Call it dbt_{firstletteroffirstname}{last_name}_day1. If your name is Taylor Swift your dataset should be: dbt_tswift_day1
threads (1 or more): Enter 2
job_execution_timeout_seconds [300]: Enter 300
Desired location option (enter a number): Enter 2 for EU. This is important!