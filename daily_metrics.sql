{{ 
  config(
    materialized='incremental',
    partition_by={
      'field': 'event_date',
      'data_type': 'date'
    }
  ) 
}}

SELECT 
  event_date,
  country,
  platform,
  dau,
  total_iap_revenue,
  total_ad_revenue,
  arpdau,
  matches_started,
  match_per_dau,
  win_ratio,
  defeat_ratio,
  server_error_per_dau
FROM {{ ref('daily_metrics_v') }}
{% if is_incremental() %}
  WHERE event_date >= (SELECT COALESCE(MAX(event_date),'1900-01-01') FROM {{ this }})
{% endif %}
