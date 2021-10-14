{{
  config(
    materialized = 'task_table',
    warehouse = target.warehouse,
    task_schedule = 'USING CRON 0 * * * * UTC',
    transient = False
  )
}}
SELECT *
FROM {{target.database}}.{{target.schema}}.PYPI_PACKAGES
