create or replace package body pkg_monthly_sales_reports as
    c_err_validation constant number := -20061;

    procedure raise_validation_error(
        p_message in varchar2
    ) as
    begin
        raise_application_error(c_err_validation, p_message);
    end raise_validation_error;

    function month_floor(
        p_month_start in date
    ) return date as
    begin
        if p_month_start is null then
            raise_validation_error('P_MONTH_START is required.');
        end if;

        return trunc(p_month_start, 'MM');
    end month_floor;

    function norm_region(
        p_region_code in varchar2
    ) return varchar2 as
    begin
        return upper(trim(p_region_code));
    end norm_region;

    procedure report_summary_by_rep(
        p_month_start in date,
        p_region_code in varchar2 default null,
        p_result      out sys_refcursor
    ) as
        l_month_start date := month_floor(p_month_start);
        l_next_month  date := add_months(month_floor(p_month_start), 1);
        l_region_code varchar2(30 char) := norm_region(p_region_code);
    begin
        open p_result for
            select sr.display_name as sales_rep,
                   sr.rep_code,
                   count(*) as total_rows_uploaded,
                   count(distinct ws.store_code) as total_stores,
                   sum(ws.units_sold) as total_units_sold,
                   sum(ws.gross_sales) as total_gross_sales,
                   round(avg(ws.gross_sales), 2) as avg_ticket
              from poc_weekly_sales ws
              join poc_sales_reps sr
                on sr.rep_code = ws.created_by
              join poc_stores st
                on st.store_code = ws.store_code
             where ws.week_start >= l_month_start
               and ws.week_start < l_next_month
               and st.active_yn = 'Y'
               and sr.active_yn = 'Y'
               and (l_region_code is null or st.region_code = l_region_code)
             group by sr.rep_code, sr.display_name
             order by sum(ws.gross_sales) desc, sr.display_name;
    end report_summary_by_rep;

    procedure report_total_products(
        p_month_start in date,
        p_region_code in varchar2 default null,
        p_result      out sys_refcursor
    ) as
        l_month_start date := month_floor(p_month_start);
        l_next_month  date := add_months(month_floor(p_month_start), 1);
        l_region_code varchar2(30 char) := norm_region(p_region_code);
    begin
        open p_result for
            with base_data as (
                select ws.product_category,
                       ws.units_sold,
                       ws.gross_sales
                  from poc_weekly_sales ws
                  join poc_stores st
                    on st.store_code = ws.store_code
                 where ws.week_start >= l_month_start
                   and ws.week_start < l_next_month
                   and st.active_yn = 'Y'
                   and (l_region_code is null or st.region_code = l_region_code)
            )
            select bd.product_category,
                   sum(bd.units_sold) as total_units_sold,
                   sum(bd.gross_sales) as total_gross_sales,
                   round(
                       100 * ratio_to_report(sum(bd.gross_sales)) over (),
                       2
                   ) as gross_sales_pct
              from base_data bd
             group by bd.product_category
             order by sum(bd.gross_sales) desc, bd.product_category;
    end report_total_products;

    procedure report_top_stores_risk(
        p_month_start        in date,
        p_region_code        in varchar2 default null,
        p_top_n              in number default 10,
        p_risk_threshold_pct in number default 20,
        p_result             out sys_refcursor
    ) as
        l_month_start   date := month_floor(p_month_start);
        l_prev_month    date := add_months(month_floor(p_month_start), -1);
        l_next_month    date := add_months(month_floor(p_month_start), 1);
        l_region_code   varchar2(30 char) := norm_region(p_region_code);
        l_top_n         number := nvl(p_top_n, 10);
        l_risk_threshold number := nvl(p_risk_threshold_pct, 20);
    begin
        if l_top_n <= 0 then
            raise_validation_error('P_TOP_N must be greater than 0.');
        end if;

        if l_risk_threshold < 0 then
            raise_validation_error('P_RISK_THRESHOLD_PCT must be 0 or greater.');
        end if;

        open p_result for
            with month_sales as (
                select ws.store_code,
                       st.store_name,
                       st.region_code,
                       sum(
                           case
                               when ws.week_start >= l_month_start
                                    and ws.week_start < l_next_month
                               then ws.gross_sales
                               else 0
                           end
                       ) as this_month_sales,
                       sum(
                           case
                               when ws.week_start >= l_prev_month
                                    and ws.week_start < l_month_start
                               then ws.gross_sales
                               else 0
                           end
                       ) as prev_month_sales
                  from poc_weekly_sales ws
                  join poc_stores st
                    on st.store_code = ws.store_code
                 where ws.week_start >= l_prev_month
                   and ws.week_start < l_next_month
                   and st.active_yn = 'Y'
                   and (l_region_code is null or st.region_code = l_region_code)
                 group by ws.store_code, st.store_name, st.region_code
            ),
            ranked_sales as (
                select ms.store_code,
                       ms.store_name,
                       ms.region_code,
                       ms.this_month_sales,
                       ms.prev_month_sales,
                       case
                           when ms.prev_month_sales > 0 then
                               round(
                                   ((ms.prev_month_sales - ms.this_month_sales) / ms.prev_month_sales) * 100,
                                   2
                               )
                           else null
                       end as decline_pct,
                       row_number() over (order by ms.this_month_sales desc, ms.store_code) as sales_rank
                  from month_sales ms
            ),
            top_stores as (
                select 'TOP_STORE' as segment_type,
                       rs.store_code,
                       rs.store_name,
                       rs.region_code,
                       rs.this_month_sales,
                       rs.prev_month_sales,
                       rs.decline_pct,
                       rs.sales_rank as priority_rank
                  from ranked_sales rs
                 where rs.sales_rank <= l_top_n
            ),
            risk_stores as (
                select 'RISK_STORE' as segment_type,
                       rs.store_code,
                       rs.store_name,
                       rs.region_code,
                       rs.this_month_sales,
                       rs.prev_month_sales,
                       rs.decline_pct,
                       row_number() over (
                           order by rs.decline_pct desc nulls last, rs.this_month_sales desc, rs.store_code
                       ) as priority_rank
                  from ranked_sales rs
                 where rs.prev_month_sales > 0
                   and rs.this_month_sales < rs.prev_month_sales
                   and rs.decline_pct >= l_risk_threshold
            )
            select x.segment_type,
                   x.priority_rank,
                   x.store_code,
                   x.store_name,
                   x.region_code,
                   x.this_month_sales,
                   x.prev_month_sales,
                   x.decline_pct
              from (
                    select segment_type,
                           priority_rank,
                           store_code,
                           store_name,
                           region_code,
                           this_month_sales,
                           prev_month_sales,
                           decline_pct
                      from top_stores
                    union all
                    select segment_type,
                           priority_rank,
                           store_code,
                           store_name,
                           region_code,
                           this_month_sales,
                           prev_month_sales,
                           decline_pct
                      from risk_stores
              ) x
             order by x.segment_type, x.priority_rank, x.store_code;
    end report_top_stores_risk;

    procedure report_kpi_header(
        p_month_start in date,
        p_region_code in varchar2 default null,
        p_result      out sys_refcursor
    ) as
        l_month_start date := month_floor(p_month_start);
        l_next_month  date := add_months(month_floor(p_month_start), 1);
        l_prev_month  date := add_months(month_floor(p_month_start), -1);
        l_region_code varchar2(30 char) := norm_region(p_region_code);
    begin
        open p_result for
            with base_data as (
                select ws.week_start,
                       ws.units_sold,
                       ws.gross_sales
                  from poc_weekly_sales ws
                  join poc_stores st
                    on st.store_code = ws.store_code
                 where ws.week_start >= l_prev_month
                   and ws.week_start < l_next_month
                   and st.active_yn = 'Y'
                   and (l_region_code is null or st.region_code = l_region_code)
            )
            select l_month_start as month_start,
                   l_next_month - 1 as month_end,
                   (
                       select s.setting_value
                         from poc_app_settings s
                        where s.setting_key = 'COMPANY_NAME'
                   ) as company_name,
                   sum(
                       case
                           when bd.week_start >= l_month_start and bd.week_start < l_next_month
                           then bd.gross_sales
                           else 0
                       end
                   ) as total_gross_sales,
                   sum(
                       case
                           when bd.week_start >= l_month_start and bd.week_start < l_next_month
                           then bd.units_sold
                           else 0
                       end
                   ) as total_units_sold,
                   round(
                       avg(
                           case
                               when bd.week_start >= l_month_start and bd.week_start < l_next_month
                               then bd.gross_sales
                               else null
                           end
                       ),
                       2
                   ) as avg_ticket,
                   round(
                       case
                           when sum(
                                case
                                    when bd.week_start >= l_prev_month and bd.week_start < l_month_start
                                    then bd.gross_sales
                                    else 0
                                end
                           ) = 0 then null
                           else
                               (
                                   (
                                       sum(
                                           case
                                               when bd.week_start >= l_month_start and bd.week_start < l_next_month
                                               then bd.gross_sales
                                               else 0
                                           end
                                       ) -
                                       sum(
                                           case
                                               when bd.week_start >= l_prev_month and bd.week_start < l_month_start
                                               then bd.gross_sales
                                               else 0
                                           end
                                       )
                                   ) /
                                   sum(
                                       case
                                           when bd.week_start >= l_prev_month and bd.week_start < l_month_start
                                           then bd.gross_sales
                                           else 0
                                       end
                                   )
                               ) * 100
                       end,
                       2
                   ) as mom_growth_pct
              from base_data bd;
    end report_kpi_header;

    procedure log_report_run(
        p_report_code   in varchar2,
        p_month_start   in date,
        p_region_code   in varchar2,
        p_requested_by  in varchar2,
        p_output_format in varchar2 default 'PDF',
        p_run_status    in varchar2 default 'SUCCESS',
        p_error_message in varchar2 default null
    ) as
        l_month_start date := month_floor(p_month_start);
        l_region_code varchar2(30 char) := norm_region(p_region_code);
        l_requested_by varchar2(255 char);
    begin
        l_requested_by := coalesce(
            p_requested_by,
            coalesce(sys_context('APEX$SESSION', 'APP_USER'), user)
        );

        insert into poc_monthly_report_run_log (
            report_code,
            month_start,
            region_code,
            requested_by,
            output_format,
            run_status,
            error_message,
            generated_at
        ) values (
            upper(trim(p_report_code)),
            l_month_start,
            l_region_code,
            l_requested_by,
            upper(trim(nvl(p_output_format, 'PDF'))),
            upper(trim(nvl(p_run_status, 'SUCCESS'))),
            p_error_message,
            systimestamp
        );
    end log_report_run;
end pkg_monthly_sales_reports;
/
