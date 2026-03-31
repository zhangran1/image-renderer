-- Copyright 2026 Google LLC. This software is provided as-is, without warranty
-- or representation for any use or purpose. Your use of it is subject to your
-- agreement with Google

SELECT * FROM ML.FORECAST(MODEL `{model_name}`,
                          STRUCT({horizon} AS horizon, 0.9 AS confidence_level))