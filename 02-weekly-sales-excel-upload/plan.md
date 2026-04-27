# Plan

## Phase 1 - Data Foundations

- Install a practical sample dataset in Oracle APEX (sales reps, stores, product categories, and sample weekly periods)
- Create/confirm tables for upload staging and processed sales with auditable ownership columns
- Define business keys (`week_start`, `store_code`, `product_category`) and align lookup values with the sample dataset

## Phase 2 - Template Download

- Build a limited downloadable Excel template with only essential upload columns
- Keep the file simple for business users (single sheet, plain headers, no formulas/macros)
- Include one example row and short field guidance for required vs optional columns

## Phase 3 - Upload and Parse

- Upload file into `APEX_APPLICATION_TEMP_FILES`
- Parse spreadsheet using APEX data parsing utilities
- Load parsed content into session-scoped staging table with uploader context
- Apply ownership defaults so uploaded rows are attributed to `APP_USER` by default

## Phase 4 - Preview Screen

- Show parsed rows in an interactive report/grid
- Highlight parse/format issues with clear row-level feedback before continue
- Display quick totals for units and gross sales
- For admins only, provide option to assign the uploaded file to a selected sales rep

## Phase 5 - Validation and Continue

- Run all business validations in Oracle APEX page flow before processing (required fields, ranges, lookups, duplicates)
- Mark row-level errors with user-friendly messages and block processing when any blocking issue exists
- Enforce authorization rules: standard users can only process their own uploads; admins can process with explicit sales-rep assignment

## Phase 6 - Process and Summary

- Process only validated rows into target sales table through package-based PL/SQL
- Capture inserted, updated, and rejected counts plus final ownership attribution
- Render summary page with totals, error details, and assignment audit information for traceability
