-- Copyright 2026 Google LLC. This software is provided as-is, without warranty
-- or representation for any use or purpose. Your use of it is subject to your
-- agreement with Google

CREATE OR REPLACE VIEW `{view_name}` AS
SELECT
  t.*
FROM
  `{source_table}` t
LEFT JOIN
  `{feedback_table}` f
ON
  t.{time_column} = f.timestamp AND f.series_id = '{series_id}'
WHERE
  f.timestamp IS NULL OR (f.label_type != 'FP' AND f.reason_category != 'NOISE')
