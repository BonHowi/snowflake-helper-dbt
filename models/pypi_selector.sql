{{
    config(
        materialized = 'sfc_task',
        sfc_warehouse = target.warehouse,
        sfc_task_after = 'pypi_selector_raw'
    )
}}
SELECT *
FROM {{target.database}}.{{target.schema}}.PYPI_PACKAGES

-- https://discourse.getdbt.com/t/issue-passing-a-ref-table-name-to-a-custom-materialization/973
-- So we can't use ref functin with ('pypi_selector_raw') for sfc_task_after = ref('pypi_selector_raw')
-- {{ref('pypi_selector_raw')}}

-- sfc_task_after = [
--     this.database,
--     this.schema,
--     'pypi_selector_raw'
-- ]|join('.')
