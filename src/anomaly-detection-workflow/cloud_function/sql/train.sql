-- Copyright 2026 Google LLC. This software is provided as-is, without warranty
-- or representation for any use or purpose. Your use of it is subject to your
-- agreement with Google

CREATE OR REPLACE MODEL `{model_name}`
OPTIONS(
  MODEL_TYPE='ARIMA_PLUS',
  TIME_SERIES_TIMESTAMP_COL='{time_column}',
  TIME_SERIES_DATA_COL='{value_column}',
  MODEL_REGISTRY='VERTEX_AI',
  VERTEX_AI_MODEL_ID='{vertex_ai_model_id}',
  VERTEX_AI_MODEL_VERSION_ALIASES=['{version_alias}']
) AS
SELECT
  {time_column},
  {value_column}
FROM
  `{view_name}`
WHERE {time_column} BETWEEN TIMESTAMP('{start_time}') AND TIMESTAMP('{end_time}')