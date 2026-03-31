-- Copyright 2026 Google LLC. This software is provided as-is, without warranty
-- or representation for any use or purpose. Your use of it is subject to your
-- agreement with Google

CREATE OR REPLACE MODEL `{project_id}.{bq_dataset}.{bq_model_name}`
OPTIONS(
  model_type='ARIMA_PLUS',
  time_series_timestamp_col='{time_column}',
  time_series_data_col='{value_column}'
) AS
SELECT
  {time_column},
  {value_column}
FROM
  `{view_name}`
WHERE {time_column} BETWEEN TIMESTAMP('{start_time}') AND TIMESTAMP('{end_time}')