-- Helper macro to help with creating the TASK sql query
{% macro create_task_sql(target_relation, warehouse, task_schedule, sql) -%}
  CREATE OR REPLACE TASK {{ target_relation }}
    WAREHOUSE = {{ warehouse }}
    SCHEDULE = '{{ task_schedule }}'
  AS
    {{ create_table_as(False, target_relation, sql) }}
{%- endmacro %}


-- Helper macro to help with resuming the task that is created in suspend state
{% macro resume_task(target_relation) -%}
  {% call statement('resume_task') -%}
    ALTER TASK {{ target_relation }} RESUME
  {%- endcall %}
{% endmacro %}


-- Materialization definition
{% materialization task_table, adapter='snowflake' %}
  {%- set identifier = model['alias'] -%}

  {%- set warehouse = config.get('warehouse') -%}
  {%- set task_schedule = config.get('task_schedule') -%}

  {%- set target_relation = this -%}
  {%- set existing_relation = load_relation(this) -%}
  --------------------------------------------------------------------------------------------------------------------

  -- setup
  {{ run_hooks(pre_hooks, inside_transaction=False) }}

  -- `BEGIN` happens here:
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

  {% set build_sql = create_task_sql(
      target_relation,
      warehouse,
      task_schedule,
      sql
    )
  %}

  -- 1. Build the sql query and execute it.
  {%- call statement('main') -%}
    {{ build_sql }}
  {%- endcall -%}

  -- 2. Resume the task that was created in suspended state.
  {% do resume_task(target_relation) %}

  --------------------------------------------------------------------------------------------------------------------
  {{ run_hooks(post_hooks, inside_transaction=True) }}

  -- `COMMIT` happens here
  {{ adapter.commit() }}

  {{ run_hooks(post_hooks, inside_transaction=False) }}

  {{ return({'relations': [target_relation]  }) }}
{%- endmaterialization %}
