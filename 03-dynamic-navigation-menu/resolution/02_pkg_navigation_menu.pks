create or replace package pkg_navigation_menu as
    procedure create_menu_entry(
        p_parent_menu_id    in poc_navigation_menu.parent_menu_id%type,
        p_menu_label        in poc_navigation_menu.menu_label%type,
        p_target_url        in poc_navigation_menu.target_url%type,
        p_icon_class        in poc_navigation_menu.icon_class%type,
        p_css_class         in poc_navigation_menu.css_class%type,
        p_js_action_name    in poc_navigation_menu.js_action_name%type,
        p_js_action_payload in poc_navigation_menu.js_action_payload%type,
        p_display_sequence  in poc_navigation_menu.display_sequence%type,
        p_is_active         in poc_navigation_menu.is_active%type default 'Y',
        p_valid_from        in poc_navigation_menu.valid_from%type default null,
        p_valid_to          in poc_navigation_menu.valid_to%type default null,
        p_menu_id           out poc_navigation_menu.menu_id%type
    );

    procedure update_menu_entry(
        p_menu_id           in poc_navigation_menu.menu_id%type,
        p_parent_menu_id    in poc_navigation_menu.parent_menu_id%type,
        p_menu_label        in poc_navigation_menu.menu_label%type,
        p_target_url        in poc_navigation_menu.target_url%type,
        p_icon_class        in poc_navigation_menu.icon_class%type,
        p_css_class         in poc_navigation_menu.css_class%type,
        p_js_action_name    in poc_navigation_menu.js_action_name%type,
        p_js_action_payload in poc_navigation_menu.js_action_payload%type,
        p_display_sequence  in poc_navigation_menu.display_sequence%type,
        p_is_active         in poc_navigation_menu.is_active%type default 'Y',
        p_valid_from        in poc_navigation_menu.valid_from%type default null,
        p_valid_to          in poc_navigation_menu.valid_to%type default null
    );

    procedure delete_menu_entry(
        p_menu_id in poc_navigation_menu.menu_id%type
    );

    procedure validate_hierarchy(
        p_menu_id        in poc_navigation_menu.menu_id%type,
        p_parent_menu_id in poc_navigation_menu.parent_menu_id%type
    );

    procedure validate_target(
        p_target_url in poc_navigation_menu.target_url%type
    );

    function get_menu_tree_json(
        p_username in varchar2
    ) return clob;

    procedure log_menu_click(
        p_menu_id          in poc_nav_menu_click_log.menu_id%type,
        p_app_user         in poc_nav_menu_click_log.app_user%type,
        p_app_session      in poc_nav_menu_click_log.app_session%type,
        p_page_id          in poc_nav_menu_click_log.page_id%type,
        p_request_context  in poc_nav_menu_click_log.request_context%type,
        p_client_ip        in poc_nav_menu_click_log.client_ip%type,
        p_user_agent       in poc_nav_menu_click_log.user_agent%type
    );
end pkg_navigation_menu;
/
