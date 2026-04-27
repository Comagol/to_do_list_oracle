# Project 03 - APEX Build Notes

Use these notes to implement the APEX pages and runtime integration for the dynamic menu using the delivered schema and package.

## 1) New APEX App Setup

- Create a new app named `POC_DYNAMIC_NAVIGATION_MENU`.
- Keep authentication simple for POC (Application Express Accounts or your current standard).
- Add one navigation entry to `Home`; runtime menu will be region-driven.

## 2) Admin Page (CRUD + Role Mapping)

Create page `10` named `Menu Admin` with:

- Region A: Interactive Grid on `POC_NAVIGATION_MENU`
  - Editable columns:
    - `P10_MENU_ID` (display only, PK)
    - `P10_PARENT_MENU_ID` (Popup LOV from `POC_NAVIGATION_MENU`)
    - `P10_MENU_LABEL` (required)
    - `P10_TARGET_URL`
    - `P10_ICON_CLASS`
    - `P10_CSS_CLASS`
    - `P10_JS_ACTION_NAME` (LOV from `POC_NAV_ALLOWED_JS_ACTION`)
    - `P10_JS_ACTION_PAYLOAD`
    - `P10_DISPLAY_SEQUENCE`
    - `P10_IS_ACTIVE`
    - `P10_VALID_FROM`
    - `P10_VALID_TO`
- Region B: Interactive Grid on `POC_NAV_MENU_ROLE`
  - Bind to selected menu item (`MENU_ID`)
  - Columns: `ROLE_CODE`, `IS_ACTIVE`, validity window
- Region C: Preview (`PL/SQL Dynamic Content`)
  - Calls `pkg_navigation_menu.get_menu_tree_json(:APP_USER)` and prints JSON.

### Server-side validations

- On create/update, call package APIs only (`create_menu_entry`, `update_menu_entry`).
- Do not write direct DML from APEX process.
- Show package error text using inline notification.

## 3) Runtime Menu Page

Create page `1` with region `Runtime Menu`:

- Type: Static Content (or Dynamic Content)
- Source SQL (for report/list rendering):

```sql
select jt.menu_id,
       jt.parent_menu_id,
       jt.menu_label,
       jt.target_url,
       jt.icon_class,
       jt.css_class,
       jt.js_action_name,
       jt.js_action_payload,
       jt.display_sequence
  from json_table(
         pkg_navigation_menu.get_menu_tree_json(:APP_USER),
         '$[*]'
         columns (
             menu_id          number         path '$.menuId',
             parent_menu_id   number         path '$.parentMenuId',
             menu_label       varchar2(200)  path '$.menuLabel',
             target_url       varchar2(2000) path '$.targetUrl',
             icon_class       varchar2(200)  path '$.iconClass',
             css_class        varchar2(200)  path '$.cssClass',
             js_action_name   varchar2(128)  path '$.jsActionName',
             js_action_payload clob          path '$.jsActionPayload',
             display_sequence number         path '$.displaySequence'
         )
       ) jt
 order by nvl(jt.parent_menu_id, 0), jt.display_sequence, jt.menu_id
```

## 4) JavaScript Action Contract

Add this app-level JavaScript function:

```javascript
window.POC_NAV_ACTIONS = {
  openModal: function(payload) {
    // Example hook: open modal or dialog region.
    console.log("openModal", payload);
  },
  runRefresh: function(payload) {
    // Example hook: refresh a region static ID passed in payload.
    if (payload && payload.regionStaticId) {
      apex.region(payload.regionStaticId).refresh();
    }
  }
};

window.invokeMenuAction = function(actionName, payloadText) {
  if (!actionName) return;
  var payload = {};
  if (payloadText) {
    try {
      payload = JSON.parse(payloadText);
    } catch (e) {
      apex.message.showErrors([{
        type: "error",
        location: "page",
        message: "Invalid JSON payload for menu action: " + actionName,
        unsafe: false
      }]);
      return;
    }
  }

  if (!window.POC_NAV_ACTIONS[actionName]) {
    apex.message.showErrors([{
      type: "error",
      location: "page",
      message: "Missing JS handler: " + actionName,
      unsafe: false
    }]);
    return;
  }

  window.POC_NAV_ACTIONS[actionName](payload);
};
```

## 5) Click Audit Integration

On menu click dynamic action:

1. If `target_url` exists, navigate.
2. If `js_action_name` exists, call `invokeMenuAction`.
3. Always call an AJAX callback process that executes:

```plsql
pkg_navigation_menu.log_menu_click(
    p_menu_id         => :P1_MENU_ID,
    p_app_user        => :APP_USER,
    p_app_session     => :APP_SESSION,
    p_page_id         => :APP_PAGE_ID,
    p_request_context => 'runtime-click',
    p_client_ip       => owa_util.get_cgi_env('REMOTE_ADDR'),
    p_user_agent      => owa_util.get_cgi_env('HTTP_USER_AGENT')
);
```

## 6) Checklist Mapping

- Nested menu CRUD: Region A + package hierarchy validation.
- Icon/CSS render: runtime region columns `icon_class` and `css_class`.
- JS action invocation: `invokeMenuAction`.
- Sequence order: query `order by` + `display_sequence`.
- Inactive hidden: package filtering `is_active` and validity window.
- Unauthorized hidden: package role filtering using `POC_APP_USER_ROLE` and `POC_NAV_MENU_ROLE`.
