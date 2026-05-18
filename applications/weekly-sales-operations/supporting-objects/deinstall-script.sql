-- Weekly Sales Operations — Deinstall (reverse dependency order)
DROP PACKAGE pkg_monthly_sales_reports;
DROP TABLE poc_monthly_report_run_log PURGE;
DROP TABLE poc_weekly_sales_stg PURGE;
DROP TABLE poc_weekly_sales PURGE;
DROP TABLE poc_upload_batch PURGE;
DROP TABLE poc_app_user_rep PURGE;
DROP TABLE poc_app_settings PURGE;
DROP TABLE poc_sales_reps PURGE;
DROP TABLE poc_product_categories PURGE;
DROP TABLE poc_stores PURGE;
