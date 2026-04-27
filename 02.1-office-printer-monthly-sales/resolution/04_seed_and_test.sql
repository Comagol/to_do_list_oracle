prompt ============================================
prompt Project 02.1 - Seed and Test
prompt ============================================

set serveroutput on

prompt ---- Optional smoke seed for one store (adjust values as needed)
declare
    l_store_count number;
begin
    select count(*)
      into l_store_count
      from poc_stores
     where store_code = 'ST999';

    if l_store_count = 0 then
        insert into poc_stores (
            store_code,
            store_name,
            region_code,
            active_yn,
            created_at
        ) values (
            'ST999',
            'Smoke Test Store',
            'NORTH',
            'Y',
            systimestamp
        );
    end if;

    commit;
end;
/

prompt ---- Report 1: Summary by rep (this month)
declare
    l_cur sys_refcursor;
begin
    pkg_monthly_sales_reports.report_summary_by_rep(
        p_month_start => trunc(sysdate, 'MM'),
        p_region_code => null,
        p_result      => l_cur
    );
    dbms_sql.return_result(l_cur);
end;
/

prompt ---- Report 2: Total products (this month)
declare
    l_cur sys_refcursor;
begin
    pkg_monthly_sales_reports.report_total_products(
        p_month_start => trunc(sysdate, 'MM'),
        p_region_code => null,
        p_result      => l_cur
    );
    dbms_sql.return_result(l_cur);
end;
/

prompt ---- Report 3: Top stores + risk stores (this month)
declare
    l_cur sys_refcursor;
begin
    pkg_monthly_sales_reports.report_top_stores_risk(
        p_month_start        => trunc(sysdate, 'MM'),
        p_region_code        => null,
        p_top_n              => 10,
        p_risk_threshold_pct => 20,
        p_result             => l_cur
    );
    dbms_sql.return_result(l_cur);
end;
/

prompt ---- KPI header
declare
    l_cur sys_refcursor;
begin
    pkg_monthly_sales_reports.report_kpi_header(
        p_month_start => trunc(sysdate, 'MM'),
        p_region_code => null,
        p_result      => l_cur
    );
    dbms_sql.return_result(l_cur);
end;
/

prompt ---- Print run audit sample
begin
    pkg_monthly_sales_reports.log_report_run(
        p_report_code   => 'RPT_SUMMARY_BY_REP',
        p_month_start   => trunc(sysdate, 'MM'),
        p_region_code   => null,
        p_requested_by  => coalesce(sys_context('APEX$SESSION', 'APP_USER'), user),
        p_output_format => 'PDF',
        p_run_status    => 'SUCCESS',
        p_error_message => null
    );
    commit;
end;
/

prompt ---- Latest log entries
select run_id,
       report_code,
       month_start,
       requested_by,
       output_format,
       run_status,
       generated_at
  from poc_monthly_report_run_log
 order by run_id desc
 fetch first 10 rows only;
