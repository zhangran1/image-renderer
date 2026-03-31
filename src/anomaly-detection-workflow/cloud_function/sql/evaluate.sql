-- Copyright 2026 Google LLC. This software is provided as-is, without warranty
-- or representation for any use or purpose. Your use of it is subject to your
-- agreement with Google

(
    SELECT
        'aic' AS metric,
        aic AS value
    FROM
        ML.ARIMA_EVALUATE(MODEL `{model_name}`)
    WHERE
        aic <> 0 -- aic == 0 indicates model failed to run.
    ORDER BY
        aic
    LIMIT 1
)
UNION ALL
(
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
)


-- This will result a table that looks like this:
-- | metric | value     |
-- ----------------------
-- | aic    | 3802.157  |
-- | mape   | 2.1667311 |