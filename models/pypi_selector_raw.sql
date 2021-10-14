{{
    config(
        materialized = 'sfc_task',
        sfc_warehouse = target.warehouse,
        sfc_task_schedule = 'USING CRON 0 * * * * UTC'
    )
}}
SELECT *
FROM {{target.database}}.{{target.schema}}.PYPI_PACKAGES_RAW
