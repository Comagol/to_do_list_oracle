create or replace package pkg_monthly_sales_reports as
    procedure report_summary_by_rep(
        p_month_start in date,
        p_region_code in varchar2 default null,
        p_result      out sys_refcursor
    );

    procedure report_total_products(
        p_month_start in date,
        p_region_code in varchar2 default null,
        p_result      out sys_refcursor
    );

    procedure report_top_stores_risk(
        p_month_start        in date,
        p_region_code        in varchar2 default null,
        p_top_n              in number default 10,
        p_risk_threshold_pct in number default 20,
        p_result             out sys_refcursor
    );

    procedure report_kpi_header(
        p_month_start in date,
        p_region_code in varchar2 default null,
        p_result      out sys_refcursor
    );

    procedure log_report_run(
        p_report_code   in varchar2,
        p_month_start   in date,
        p_region_code   in varchar2,
        p_requested_by  in varchar2,
        p_output_format in varchar2 default 'PDF',
        p_run_status    in varchar2 default 'SUCCESS',
        p_error_message in varchar2 default null
    );
end pkg_monthly_sales_reports;
/
