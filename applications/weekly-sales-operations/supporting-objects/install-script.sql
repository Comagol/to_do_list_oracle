-- ============================================================
-- Weekly Sales Operations — Supporting Objects Install
-- For SQL*Plus / SQLcl only (uses @@ file includes).
--
-- APEX SQL Scripts cannot run this file (0 statements error).
-- In App Builder use: install-script-apex.sql instead.
-- Or run 01 → 02 → 03 → 04 → 05 separately in order.
-- ============================================================

@@01_core_sales_schema.sql
@@02_seed_sample_data.sql
@@03_reporting_objects.sql
@@04_pkg_monthly_sales_reports.pks
@@05_pkg_monthly_sales_reports.pkb
