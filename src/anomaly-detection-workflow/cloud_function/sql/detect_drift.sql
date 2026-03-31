-- Copyright 2026 Google LLC. This software is provided as-is, without warranty
-- or representation for any use or purpose. Your use of it is subject to your
-- agreement with Google

-- This query detects data drift by comparing the statistical properties of the
-- new data with the training data.

-- Declare variables to be passed in from the calling environment
DECLARE model_name, time_column, value_column, source_table, start_time, end_time, audit_table STRING;

-- Set the variables with placeholder values. In a real scenario, these would be
-- parameterized by the scheduled query or calling script.
SET (model_name, time_column, value_column, source_table, start_time, end_time, audit_table) = (
    SELECT AS STRUCT
        'anomaly_detection_model', -- Example model name
        'ts',                     -- Example time column
        'value',                  -- Example value column
        'simulation_data.anomaly_time_series', -- Example source table
        '2023-01-01T00:00:00',    -- Example start_time
        '2023-01-31T23:59:59',    -- Example end_time
        'model_ops.audit_log'     -- Example audit log table
);

-- In a real implementation, you would get the training details from the audit log like this:
SET (source_table, start_time, end_time) = (
    SELECT AS STRUCT
        source_table,
        JSON_EXTRACT_SCALAR(parameters, '$.start_time'),
        JSON_EXTRACT_SCALAR(parameters, '$.end_time')
    FROM `{audit_table}`
    WHERE workflow_name = 'anomaly-detection' AND action = 'train'
    ORDER BY timestamp DESC
    LIMIT 1
);

WITH TrainingDataStats AS (
    -- Calculate statistics for the training data
    SELECT
        AVG({value_column}) AS mean_value,
        STDDEV({value_column}) AS stddev_value
    FROM
        `{source_table}`
    WHERE {time_column} BETWEEN TIMESTAMP(start_time) AND TIMESTAMP(end_time)
),
NewDataStats AS (
    -- Calculate statistics for the new data (post-training)
    SELECT
        AVG({value_column}) AS mean_value,
        STDDEV({value_column}) AS stddev_value
    FROM
        `{source_table}`
    WHERE {time_column} > TIMESTAMP(end_time)
)
-- Compare the statistics and determine if there is drift
SELECT
    training.mean_value AS training_mean,
    training.stddev_value AS training_stddev,
    new_data.mean_value AS new_data_mean,
    new_data.stddev_value AS new_data_stddev,
    -- Drift is detected if the new mean is more than 2 standard deviations away
    -- from the training mean.
    ABS(new_data.mean_value - training.mean_value) > 2 * training.stddev_value AS drift_detected
FROM
    TrainingDataStats AS training,
    NewDataStats AS new_data;
