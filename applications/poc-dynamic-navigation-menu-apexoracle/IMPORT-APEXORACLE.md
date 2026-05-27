# Import on apex.oracle.com (workspace FRAN_COMABELLA)

## 1. Database objects (SQL Workshop first)

Run as the parsing schema user (**WKSP_FRANCOMABELLA**):

`install-database-apexoracle.sql` (in this folder)

Or run the scripts under `../../03-dynamic-navigation-menu/resolution/` in order.

## 2. Import the application

Use **`poc-dynamic-navigation-menu-apexoracle.zip`** (not the OCI/COMAGOL zip).

- File type: **Application, Page or Component Export**
- Workspace: **FRAN_COMABELLA**
- Parsing schema: **WKSP_FRANCOMABELLA**
- Import as: **Auto Assign New Application ID**

> The previous `restDataSource` component settings (`oracleCloudAppsSaas`, `oracleCloudAppsBoss`) that triggered the "ORDS Authentication request failed" error have been removed from `shared-components/component-settings.apx`. This app uses only local database sources — no REST data sources are needed. Re-export a fresh zip from the APEXLang source before importing.

## 3. Run the app

App Builder → your new app → **Run**.
