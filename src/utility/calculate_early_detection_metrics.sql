-- Copyright 2026 Google LLC. This software is provided as-is, without warranty
-- or representation for any use or purpose. Your use of it is subject to your
-- agreement with Google

-- Calculate metrics for Early Detection Workflow: False Alarm Rate & Lead Time.
-- This query extracts the `series_id` (bq_table) from the JSON parameters column in the audit log.

WITH AlertData AS (
    SELECT
        -- Extract series_id from JSON parameters (assuming bq_table is the series identifier)
        JSON_EXTRACT_SCALAR(a.parameters, '$.bq_table') AS series_id,
        a.timestamp AS alert_time,
        f.label_type,
        f.feedback_at AS action_time
    FROM
        `{project_id}.model_ops.audit_log` a
    LEFT JOIN
        `{project_id}.feedbacks.monthly_feedback` f
        ON JSON_EXTRACT_SCALAR(a.parameters, '$.bq_table') = f.series_id 
        -- Join on approximate time (within same hour) to match alert with feedback
        AND TIMESTAMP_TRUNC(a.timestamp, HOUR) = TIMESTAMP_TRUNC(f.timestamp, HOUR)
    WHERE
        a.workflow_name = 'early-detection'
        AND a.action = 'forecast_and_publish'
        -- Only count instances where an alert was actually published
        AND JSON_EXTRACT_SCALAR(a.parameters, '$.status') = 'alert published'
)

SELECT
    -- 1. False Alarm Rate (Lower is better)
    -- Proportion of alerts marked as False Positive (FP) by users
    COUNTIF(label_type = 'FP') AS false_alarms,
    COUNT(*) AS total_alerts,
    CASE 
        WHEN COUNT(*) = 0 THEN 0 
        ELSE COUNTIF(label_type = 'FP') / COUNT(*) 
    END AS false_alarm_rate,

    -- 2. Average Lead Time for True Positives (Higher is generally better)
    -- Measures time between the Alert and the User Feedback (Action)
    -- Filter out FPs because lead time is irrelevant for false alarms
    AVG(CASE 
        WHEN label_type IS NULL OR label_type != 'FP' 
        THEN TIMESTAMP_DIFF(action_time, alert_time, MINUTE) 
        ELSE NULL 
    END) AS avg_lead_time_minutes

FROM AlertData
