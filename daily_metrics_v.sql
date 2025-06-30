{{ config(materialized='view') }}

WITH metrics_agg AS (
  SELECT
    event_date,
    country,
    platform,
    COUNT(DISTINCT user_id) AS dau,
    SUM(iap_revenue) AS total_iap_revenue,
    SUM(ad_revenue) AS total_ad_revenue,
    SUM(match_start_count) AS matches_started,
    SUM(match_end_count) AS matches_ended,
    SUM(victory_count) AS victories,
    SUM(defeat_count) AS defeats,
    SUM(server_connection_error) AS server_errors
  FROM {{ source('events', 'user_metrics') }}
  GROUP BY 1, 2, 3
)

SELECT
  event_date,
  country,
  platform,
  dau,
  ROUND(total_iap_revenue, 2) AS total_iap_revenue,
  ROUND(total_ad_revenue, 2) AS total_ad_revenue,
  ROUND(SAFE_DIVIDE(total_iap_revenue + total_ad_revenue, NULLIF(dau, 0)), 2) AS arpdau,
  matches_started,
  ROUND(SAFE_DIVIDE(matches_started, NULLIF(dau, 0)), 2) AS match_per_dau,
  ROUND(SAFE_DIVIDE(victories, NULLIF(matches_ended, 0)), 4) AS win_ratio,
  ROUND(SAFE_DIVIDE(defeats, NULLIF(matches_ended, 0)), 4) AS defeat_ratio,
  ROUND(SAFE_DIVIDE(server_errors, NULLIF(dau, 0)), 2) AS server_error_per_dau
FROM metrics_agg
