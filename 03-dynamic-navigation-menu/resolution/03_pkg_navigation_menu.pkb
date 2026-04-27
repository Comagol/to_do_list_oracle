create or replace package body pkg_navigation_menu as
    c_err_validation         constant number := -20051;
    c_url_pattern            constant varchar2(1000 char) :=
        '^(f\?p=|/ords/|https?://|/)[[:print:]]*$';
    c_js_name_pattern        constant varchar2(200 char) :=
        '^[A-Za-z][A-Za-z0-9_\.]{0,127}$';

    procedure raise_validation_error(
        p_message in varchar2
    ) as
    begin
        raise_application_error(c_err_validation, p_message);
    end raise_validation_error;

    function get_current_user
        return varchar2
    as
    begin
        return coalesce(sys_context('APEX$SESSION', 'APP_USER'), user);
    end get_current_user;

    procedure validate_validity_window(
        p_valid_from in poc_navigation_menu.valid_from%type,
        p_valid_to   in poc_navigation_menu.valid_to%type
    ) as
    begin
        if p_valid_from is not null
           and p_valid_to is not null
           and p_valid_to < p_valid_from then
            raise_validation_error('VALID_TO cannot be earlier than VALID_FROM.');
        end if;
    end validate_validity_window;

    procedure validate_js_action_name(
        p_js_action_name in poc_navigation_menu.js_action_name%type
    ) as
        l_dummy pls_integer;
    begin
        if p_js_action_name is null then
            return;
        end if;

        if regexp_like(p_js_action_name, c_js_name_pattern) = false then
            raise_validation_error('Invalid JavaScript action name format.');
        end if;

        select 1
          into l_dummy
          from poc_nav_allowed_js_action a
         where a.action_name = p_js_action_name
           and a.is_active = 'Y';
    exception
        when no_data_found then
            raise_validation_error(
                'JavaScript action "' || p_js_action_name || '" is not in the allowlist.'
            );
    end validate_js_action_name;

    procedure validate_hierarchy(
        p_menu_id        in poc_navigation_menu.menu_id%type,
        p_parent_menu_id in poc_navigation_menu.parent_menu_id%type
    ) as
        l_dummy pls_integer;
    begin
        if p_parent_menu_id is null then
            return;
        end if;

        if p_menu_id is not null and p_menu_id = p_parent_menu_id then
            raise_validation_error('A menu entry cannot be parent of itself.');
        end if;

        select 1
          into l_dummy
          from poc_navigation_menu pm
         where pm.menu_id = p_parent_menu_id;

        if p_menu_id is not null then
            select count(*)
              into l_dummy
              from (
                    select m.menu_id
                      from poc_navigation_menu m
                     start with m.menu_id = p_parent_menu_id
                    connect by prior m.parent_menu_id = m.menu_id
                   )
             where menu_id = p_menu_id;

            if l_dummy > 0 then
                raise_validation_error('Parent assignment creates a cycle in the menu hierarchy.');
            end if;
        end if;
    exception
        when no_data_found then
            raise_validation_error('Parent menu does not exist.');
    end validate_hierarchy;

    procedure validate_target(
        p_target_url in poc_navigation_menu.target_url%type
    ) as
    begin
        if p_target_url is null then
            return;
        end if;

        if regexp_like(p_target_url, c_url_pattern, 'i') = false then
            raise_validation_error(
                'Invalid TARGET_URL. Allowed prefixes: f?p=, /ords/, /, http://, https://'
            );
        end if;
    end validate_target;

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
    ) as
        l_current_user poc_navigation_menu.created_by%type;
    begin
        if p_menu_label is null then
            raise_validation_error('MENU_LABEL is required.');
        end if;

        validate_hierarchy(
            p_menu_id        => null,
            p_parent_menu_id => p_parent_menu_id
        );

        validate_target(p_target_url => p_target_url);
        validate_js_action_name(p_js_action_name => p_js_action_name);
        validate_validity_window(
            p_valid_from => p_valid_from,
            p_valid_to   => p_valid_to
        );

        l_current_user := get_current_user();

        insert into poc_navigation_menu (
            parent_menu_id,
            menu_label,
            target_url,
            icon_class,
            css_class,
            js_action_name,
            js_action_payload,
            display_sequence,
            is_active,
            valid_from,
            valid_to,
            created_at,
            created_by,
            updated_at,
            updated_by
        ) values (
            p_parent_menu_id,
            trim(p_menu_label),
            p_target_url,
            p_icon_class,
            p_css_class,
            p_js_action_name,
            p_js_action_payload,
            p_display_sequence,
            p_is_active,
            p_valid_from,
            p_valid_to,
            systimestamp,
            l_current_user,
            systimestamp,
            l_current_user
        )
        returning menu_id
             into p_menu_id;
    end create_menu_entry;

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
    ) as
        l_current_user poc_navigation_menu.updated_by%type;
    begin
        if p_menu_id is null then
            raise_validation_error('MENU_ID is required for update.');
        end if;

        if p_menu_label is null then
            raise_validation_error('MENU_LABEL is required.');
        end if;

        validate_hierarchy(
            p_menu_id        => p_menu_id,
            p_parent_menu_id => p_parent_menu_id
        );

        validate_target(p_target_url => p_target_url);
        validate_js_action_name(p_js_action_name => p_js_action_name);
        validate_validity_window(
            p_valid_from => p_valid_from,
            p_valid_to   => p_valid_to
        );

        l_current_user := get_current_user();

        update poc_navigation_menu m
           set m.parent_menu_id    = p_parent_menu_id,
               m.menu_label        = trim(p_menu_label),
               m.target_url        = p_target_url,
               m.icon_class        = p_icon_class,
               m.css_class         = p_css_class,
               m.js_action_name    = p_js_action_name,
               m.js_action_payload = p_js_action_payload,
               m.display_sequence  = p_display_sequence,
               m.is_active         = p_is_active,
               m.valid_from        = p_valid_from,
               m.valid_to          = p_valid_to,
               m.updated_at        = systimestamp,
               m.updated_by        = l_current_user
         where m.menu_id = p_menu_id;

        if sql%rowcount = 0 then
            raise_validation_error('MENU_ID does not exist.');
        end if;
    end update_menu_entry;

    procedure delete_menu_entry(
        p_menu_id in poc_navigation_menu.menu_id%type
    ) as
    begin
        delete from poc_navigation_menu m
         where m.menu_id = p_menu_id;

        if sql%rowcount = 0 then
            raise_validation_error('MENU_ID does not exist.');
        end if;
    end delete_menu_entry;

    function get_menu_tree_json(
        p_username in varchar2
    ) return clob as
        l_json clob;
    begin
        with user_roles as (
            select ur.role_code
              from poc_app_user_role ur
             where ur.app_user = p_username
               and ur.is_active = 'Y'
               and (ur.valid_from is null or ur.valid_from <= systimestamp)
               and (ur.valid_to is null or ur.valid_to >= systimestamp)
        ),
        menu_rows as (
            select m.menu_id,
                   m.parent_menu_id,
                   m.menu_label,
                   m.target_url,
                   m.icon_class,
                   m.css_class,
                   case
                       when exists (
                           select 1
                             from poc_nav_allowed_js_action a
                            where a.action_name = m.js_action_name
                              and a.is_active = 'Y'
                       ) then m.js_action_name
                       else null
                   end as js_action_name,
                   m.js_action_payload,
                   m.display_sequence
              from poc_navigation_menu m
             where m.is_active = 'Y'
               and (m.valid_from is null or m.valid_from <= systimestamp)
               and (m.valid_to is null or m.valid_to >= systimestamp)
               and (
                    not exists (
                        select 1
                          from poc_nav_menu_role mr
                         where mr.menu_id = m.menu_id
                           and mr.is_active = 'Y'
                           and (mr.valid_from is null or mr.valid_from <= systimestamp)
                           and (mr.valid_to is null or mr.valid_to >= systimestamp)
                    )
                    or exists (
                        select 1
                          from poc_nav_menu_role mr
                          join user_roles ur
                            on ur.role_code = mr.role_code
                         where mr.menu_id = m.menu_id
                           and mr.is_active = 'Y'
                           and (mr.valid_from is null or mr.valid_from <= systimestamp)
                           and (mr.valid_to is null or mr.valid_to >= systimestamp)
                    )
               )
        )
        select coalesce(
                   json_arrayagg(
                       json_object(
                           'menuId'          value r.menu_id,
                           'parentMenuId'    value r.parent_menu_id,
                           'menuLabel'       value r.menu_label,
                           'targetUrl'       value r.target_url,
                           'iconClass'       value r.icon_class,
                           'cssClass'        value r.css_class,
                           'jsActionName'    value r.js_action_name,
                           'jsActionPayload' value r.js_action_payload format json,
                           'displaySequence' value r.display_sequence
                       returning clob
                       )
                       order by nvl(r.parent_menu_id, 0), r.display_sequence, r.menu_id
                       returning clob
                   ),
                   to_clob('[]')
               )
          into l_json
          from menu_rows r;

        return l_json;
    exception
        when others then
            raise_application_error(
                -20099,
                'get_menu_tree_json failed: '
                || sqlerrm
                || ' | '
                || dbms_utility.format_error_backtrace
            );
    end get_menu_tree_json;

    procedure log_menu_click(
        p_menu_id          in poc_nav_menu_click_log.menu_id%type,
        p_app_user         in poc_nav_menu_click_log.app_user%type,
        p_app_session      in poc_nav_menu_click_log.app_session%type,
        p_page_id          in poc_nav_menu_click_log.page_id%type,
        p_request_context  in poc_nav_menu_click_log.request_context%type,
        p_client_ip        in poc_nav_menu_click_log.client_ip%type,
        p_user_agent       in poc_nav_menu_click_log.user_agent%type
    ) as
    begin
        insert into poc_nav_menu_click_log (
            menu_id,
            app_user,
            app_session,
            page_id,
            click_ts,
            request_context,
            client_ip,
            user_agent
        ) values (
            p_menu_id,
            p_app_user,
            p_app_session,
            p_page_id,
            systimestamp,
            p_request_context,
            p_client_ip,
            p_user_agent
        );
    end log_menu_click;
end pkg_navigation_menu;
/
