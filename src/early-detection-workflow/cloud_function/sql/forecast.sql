-- Copyright 2026 Google LLC. This software is provided as-is, without warranty
-- or representation for any use or purpose. Your use of it is subject to your
-- agreement with Google

SELECT *
FROM
  ML.FORECAST(MODEL `{project_id}.{bq_dataset}.{bq_model_name}`,
              STRUCT(30 AS horizon, 0.8 AS confidence_level))