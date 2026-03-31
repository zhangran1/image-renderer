-- Copyright 2026 Google LLC. This software is provided as-is, without warranty
-- or representation for any use or purpose. Your use of it is subject to your
-- agreement with Google

-- This script generates three tables with simulated time series data in your BigQuery dataset.
-- You need to replace `your_project_id` and `your_dataset_id` with your actual project and dataset IDs.

-- Generate a base timestamp array
CREATE OR REPLACE TEMP TABLE timestamps AS (
  SELECT ts
  FROM UNNEST(GENERATE_TIMESTAMP_ARRAY('2025-01-01 00:00:00', '2025-03-31 23:00:00', INTERVAL 1 HOUR)) AS ts
);

-- Table 1: Normal with seasonality and smoother noise
CREATE OR REPLACE TABLE `your_project_id.your_dataset_id.normal_time_series` AS (
  SELECT
    ts,
    -- Seasonality (daily) + some random noise
    (10 * SIN(EXTRACT(HOUR FROM ts) * 2 * ACOS(-1) / 24) + 5 * COS(EXTRACT(HOUR FROM ts) * 2 * ACOS(-1) / 12) + 50 + (RAND() * 4 - 2)) AS value
  FROM timestamps
);

-- Table 2: With an anomaly (a sudden spike) and smoother noise
CREATE OR REPLACE TABLE `your_project_id.your_dataset_id.anomaly_time_series` AS (
  SELECT
    ts,
    (10 * SIN(EXTRACT(HOUR FROM ts) * 2 * ACOS(-1) / 24) + 50 + (RAND() * 4 - 2)) +
    -- Add a large spike at a specific time
    IF(ts = '2025-02-15 10:00:00', 100, 0) AS value
  FROM timestamps
);

-- Table 3: With a gradual change point simulating CPU increase
CREATE OR REPLACE TABLE `your_project_id.your_dataset_id.change_point_time_series` AS (
  SELECT
    ts,
    -- Cap the value at 100 to simulate CPU percentage
    LEAST(100,
      -- Base value with seasonality and smoother noise
      (5 * SIN(EXTRACT(HOUR FROM ts) * 2 * ACOS(-1) / 24) + 20 + (RAND() * 4 - 2)) +
      
      -- 1. False Positive (FP): A short-lived "noise" spike that looks like a trend start
      -- Occurs around Feb 10
      IF(ts BETWEEN '2025-02-10 08:00:00' AND '2025-02-10 12:00:00', 40, 0) +

      -- 2. True Positive (TP): Gradual increase simulating CPU saturation
      -- Starts Mar 01, but we simulate a "Fix/Restart" on Mar 10 where it drops back down
      IF(ts > '2025-03-01 00:00:00' AND ts < '2025-03-10 12:00:00',
          -- Logistic growth
          75 / (1 + EXP(-0.05 * (TIMESTAMP_DIFF(ts, '2025-03-01 00:00:00', HOUR) - 168))),
      0) +

      -- 3. False Negative (FN): A very rapid spike that might be missed or detected too late
      -- Occurs Mar 20
      IF(ts BETWEEN '2025-03-20 14:00:00' AND '2025-03-20 16:00:00', 60, 0)
    ) AS value
  FROM timestamps
);

-- You can now query the generated tables, for example:
-- SELECT * FROM `your_project_id.your_dataset_id.normal_time_series` ORDER BY ts;
-- SELECT * FROM `your_project_id.your_dataset_id.anomaly_time_series` ORDER BY ts;
-- SELECT * FROM `your_project_id.your_dataset_id.change_point_time_series` ORDER BY ts;