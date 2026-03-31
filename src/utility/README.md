# Utility Folder

This folder contains utility scripts and configurations for generating simulation data in Google BigQuery.

## Contents

-   `generate_simulation_data.sql`: A SQL script that defines the schema and populates three BigQuery tables (`normal_time_series`, `anomaly_time_series`, `change_point_time_series`) with simulated time series data. The script includes placeholders for `your_project_id` and `your_dataset_id` which are replaced at runtime. The `change_point_time_series` is designed to simulate a gradual CPU percentage increase, capped at 100%.

-   `run_simulation_data_generation.py`: A Python script responsible for:
    -   Reading the `generate_simulation_data.sql` file.
    -   Replacing the `your_project_id` and `your_dataset_id` placeholders with values provided via command-line arguments.
    -   Initializing a Google BigQuery client.
    -   Checking if the specified BigQuery dataset exists and creating it in the `US` location if it does not.
    -   Executing the modified SQL script in BigQuery to create or replace the simulation data tables.

-   `create_monthly_feedback_table.py`: A Python script that:
    -   Initializes a BigQuery client.
    -   Creates a dataset (default: `feedbacks`) if it doesn't exist.
        -   Creates a table (default: `monthly_feedback`) with a specific schema including `series_id`, `timestamp`, `label_type`, `reason_category`, and a default timestamp for `feedback_at`. (Note: `CHECK` constraints are omitted as they are not supported in all BigQuery environments).
    
    -   `populate_anomaly_detection_feedback.py`: A Python script that inserts sample feedback data into the `monthly_feedback` table. It helps simulate user feedback for testing the training view and evaluation metrics.
        -   `populate_early_detection_feedback.py`: A Python script that inserts sample feedback data specifically tailored for the `early-detection-workflow` (e.g., `change_point_time_series`) to test the filtering view logic.

-   `run_early_detection_metrics.py`: A Python script that calculates key performance metrics for the Early Detection workflow, such as False Alarm Rate and Average Lead Time, by joining audit logs with the feedback table.
-   `pyproject.toml`: Defines project metadata and dependencies.
-   `.python-version`: Specifies the Python version used for this project.
-   `uv.lock`: A lock file for managing Python dependencies.

## Setup

To run the Python script, you need to have the `google-cloud-bigquery` library installed. You can install it using `pip`:

```bash
pip install google-cloud-bigquery
```

Ensure your Google Cloud environment is authenticated and has the necessary permissions to create datasets and tables in BigQuery for the specified project.

## Usage

To generate the simulation data, run the `run_simulation_data_generation.py` script with your Google Cloud project ID and BigQuery dataset ID:

```bash
python run_simulation_data_generation.py --project_id your-gcp-project-id --dataset_id your_bigquery_dataset_id
```

To create the monthly feedback table:

```bash
python create_monthly_feedback_table.py --project_id your-gcp-project-id --dataset_id feedbacks --table_name monthly_feedback
```

To populate the feedback table with sample data for anomaly detection:

```bash
python populate_anomaly_detection_feedback.py --project_id your-gcp-project-id --dataset_id feedbacks --table_name monthly_feedback
```

To populate the feedback table with sample data for early detection:

```bash
python populate_early_detection_feedback.py --project_id your-gcp-project-id --dataset_id feedbacks --table_name monthly_feedback
```

To calculate False Alarm Rate and Average Lead Time for the Early Detection Workflow:

```bash
python run_early_detection_metrics.py --project_id your-gcp-project-id
```

Replace `your-gcp-project-id` with your actual Google Cloud project ID.

## Data Schema

The following tables will be created in your specified BigQuery dataset:

-   `normal_time_series`: Contains simulated time series data with seasonality and some random noise.
-   `anomaly_time_series`: Contains simulated time series data with an anomaly (a sudden spike) at a specific timestamp.
-   `change_point_time_series`: Contains simulated time series data with a gradual increase after a specific change point, capped at 100%, simulating CPU percentage.

Each table will have at least the following columns:

-   `ts`: TIMESTAMP, the timestamp of the data point.
-   `value`: FLOAT, the simulated value.
