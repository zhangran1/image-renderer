-- Copyright 2026 Google LLC. This software is provided as-is, without warranty
-- or representation for any use or purpose. Your use of it is subject to your
-- agreement with Google

WITH ModelMetrics AS (
    SELECT
        'aic' AS metric,
        aic AS value
    FROM
        ML.ARIMA_EVALUATE(MODEL `{model_name}`)
    WHERE
        aic <> 0
    ORDER BY
        aic
    LIMIT 1
),
MAPEMetrics AS (
    SELECT
        'mape' AS metric,
        mean_absolute_percentage_error AS value
    FROM
        ML.EVALUATE(MODEL `{model_name}`,
            (
                SELECT
                    *
                FROM
                    `{source_table}`
                WHERE
                    {time_column} >= TIMESTAMP('{eval_start_time}')
            )
        )
),
AnomalyDetection AS (
    SELECT
        {time_column} as timestamp,
        is_anomaly
    FROM
        ML.DETECT_ANOMALIES(
            MODEL `{model_name}`,
            STRUCT(0.95 AS anomaly_prob_threshold),
            (
                SELECT
                    *
                FROM
                    `{source_table}`
                WHERE
                    {time_column} >= TIMESTAMP('{eval_start_time}')
            )
        )
),
FeedbackData AS (
    SELECT
        timestamp,
        label_type
    FROM
        `{feedback_table}`
    WHERE
        series_id = '{series_id}'
        AND timestamp >= TIMESTAMP('{eval_start_time}')
),
JoinedData AS (
    SELECT
        d.timestamp,
        d.is_anomaly,
        f.label_type
    FROM
        AnomalyDetection d
    LEFT JOIN
        FeedbackData f
    ON
        d.timestamp = f.timestamp
),
ConfusionMatrix AS (
    SELECT
        -- TP: Detected as anomaly AND NOT marked as FP
        COUNTIF(is_anomaly = TRUE AND (label_type IS NULL OR label_type != 'FP')) AS tp,
        
        -- FP: Detected as anomaly AND marked as FP
        COUNTIF(is_anomaly = TRUE AND label_type = 'FP') AS fp,
        
        -- FN: Not detected as anomaly AND marked as FN
        COUNTIF(is_anomaly = FALSE AND label_type = 'FN') AS fn
    FROM
        JoinedData
),
PrecisionRecall AS (
    SELECT
        'precision' AS metric,
        CASE 
            WHEN (tp + fp) = 0 THEN NULL 
            ELSE tp / (tp + fp) 
        END AS value
    FROM
        ConfusionMatrix
    UNION ALL
    SELECT
        'recall' AS metric,
        CASE 
            WHEN (tp + fn) = 0 THEN NULL 
            ELSE tp / (tp + fn) 
        END AS value
    FROM
        ConfusionMatrix
)

SELECT * FROM ModelMetrics
UNION ALL
SELECT * FROM MAPEMetrics
UNION ALL
SELECT * FROM PrecisionRecall
