prompt ============================================
prompt Project 03 - Seed and Test Script
prompt ============================================

set serveroutput on

declare
    l_root_admin_id   poc_navigation_menu.menu_id%type;
    l_user_mgmt_id    poc_navigation_menu.menu_id%type;
    l_dashboard_id    poc_navigation_menu.menu_id%type;
    l_reports_id      poc_navigation_menu.menu_id%type;
    l_hidden_id       poc_navigation_menu.menu_id%type;
    l_json_admin      clob;
    l_json_analyst    clob;
begin
    -- Reset sample data for repeatable local testing.
    delete from poc_nav_menu_click_log;
    delete from poc_nav_menu_role;
    delete from poc_app_user_role;
    delete from poc_navigation_menu;
    delete from poc_nav_allowed_js_action;

    insert into poc_nav_allowed_js_action (action_name, description)
    values ('openModal', 'Open modal dialog with payload');

    insert into poc_nav_allowed_js_action (action_name, description)
    values ('runRefresh', 'Refresh region or page section');

    insert into poc_app_user_role (app_user, role_code)
    values ('ADMIN_USER', 'ADMIN');

    insert into poc_app_user_role (app_user, role_code)
    values ('ANALYST_USER', 'ANALYST');

    pkg_navigation_menu.create_menu_entry(
        p_parent_menu_id    => null,
        p_menu_label        => 'Administration',
        p_target_url        => null,
        p_icon_class        => 'fa fa-cog',
        p_css_class         => 'is-admin',
        p_js_action_name    => null,
        p_js_action_payload => null,
        p_display_sequence  => 10,
        p_is_active         => 'Y',
        p_valid_from        => null,
        p_valid_to          => null,
        p_menu_id           => l_root_admin_id
    );

    pkg_navigation_menu.create_menu_entry(
        p_parent_menu_id    => l_root_admin_id,
        p_menu_label        => 'User Management',
        p_target_url        => 'f?p=&APP_ID.:20:&SESSION.::&DEBUG.:::',
        p_icon_class        => 'fa fa-users',
        p_css_class         => null,
        p_js_action_name    => null,
        p_js_action_payload => null,
        p_display_sequence  => 20,
        p_is_active         => 'Y',
        p_valid_from        => null,
        p_valid_to          => null,
        p_menu_id           => l_user_mgmt_id
    );

    pkg_navigation_menu.create_menu_entry(
        p_parent_menu_id    => null,
        p_menu_label        => 'Dashboard',
        p_target_url        => 'f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::',
        p_icon_class        => 'fa fa-dashboard',
        p_css_class         => null,
        p_js_action_name    => null,
        p_js_action_payload => null,
        p_display_sequence  => 30,
        p_is_active         => 'Y',
        p_valid_from        => null,
        p_valid_to          => null,
        p_menu_id           => l_dashboard_id
    );

    pkg_navigation_menu.create_menu_entry(
        p_parent_menu_id    => null,
        p_menu_label        => 'Reports',
        p_target_url        => null,
        p_icon_class        => 'fa fa-chart-line',
        p_css_class         => null,
        p_js_action_name    => 'openModal',
        p_js_action_payload => '{"dialog":"monthlySales","mode":"preview"}',
        p_display_sequence  => 40,
        p_is_active         => 'Y',
        p_valid_from        => null,
        p_valid_to          => null,
        p_menu_id           => l_reports_id
    );

    pkg_navigation_menu.create_menu_entry(
        p_parent_menu_id    => null,
        p_menu_label        => 'Deprecated Option',
        p_target_url        => '/legacy',
        p_icon_class        => null,
        p_css_class         => 'is-hidden',
        p_js_action_name    => null,
        p_js_action_payload => null,
        p_display_sequence  => 999,
        p_is_active         => 'N',
        p_valid_from        => null,
        p_valid_to          => null,
        p_menu_id           => l_hidden_id
    );

    insert into poc_nav_menu_role (menu_id, role_code)
    values (l_root_admin_id, 'ADMIN');

    insert into poc_nav_menu_role (menu_id, role_code)
    values (l_user_mgmt_id, 'ADMIN');

    insert into poc_nav_menu_role (menu_id, role_code)
    values (l_reports_id, 'ANALYST');

    l_json_admin := pkg_navigation_menu.get_menu_tree_json('ADMIN_USER');
    l_json_analyst := pkg_navigation_menu.get_menu_tree_json('ANALYST_USER');

    dbms_output.put_line('ADMIN_USER menu JSON:');
    dbms_output.put_line(dbms_lob.substr(l_json_admin, 32000, 1));
    dbms_output.put_line('ANALYST_USER menu JSON:');
    dbms_output.put_line(dbms_lob.substr(l_json_analyst, 32000, 1));

    pkg_navigation_menu.log_menu_click(
        p_menu_id         => l_dashboard_id,
        p_app_user        => 'ADMIN_USER',
        p_app_session     => '123456',
        p_page_id         => 1,
        p_request_context => 'seed-test',
        p_client_ip       => '127.0.0.1',
        p_user_agent      => 'SQL-TEST'
    );

    commit;
end;
/

prompt ---- Validation Check: unauthorized entries hidden
select m.menu_label
  from poc_navigation_menu m
 where m.menu_id in (
    select jt.menu_id
      from json_table(
             pkg_navigation_menu.get_menu_tree_json('ANALYST_USER'),
             '$[*]'
             columns (
                 menu_id number path '$.menuId'
             )
           ) jt
 )
 order by m.display_sequence, m.menu_id;

prompt ---- Validation Check: click logging
select app_user,
       menu_id,
       click_ts
  from poc_nav_menu_click_log
 order by click_log_id desc;
