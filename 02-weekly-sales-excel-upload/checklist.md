# Checklist

## Build Checklist

- [x] Sample dataset is installed in Oracle APEX and includes sales reps, stores, categories, and sample weekly periods
- [x] Limited Excel template can be downloaded from the app with only essential columns
- [x] Template remains simple to fill (single sheet, plain headers, no formulas/macros)
- [x] Upload stores file in `APEX_APPLICATION_TEMP_FILES`
- [x] Parse logic reads uploaded rows correctly into staging with uploader context
- [x] Preview screen shows parsed data, row-level issues, and quick totals before commit
- [x] Admin-only assignment option allows setting a target sales rep for the file
- [x] Summary page shows processed totals, errors, and final ownership attribution

## Validation Checklist

- [x] All business validations run in Oracle APEX page flow before processing
- [x] Missing `week_start` is blocked
- [x] Unknown `store_code` is flagged
- [x] Invalid numeric values are rejected
- [x] Duplicate business keys are handled correctly
- [x] Standard users cannot assign uploads to other sales reps
- [x] Admin reassignment is allowed only for authorized admin users
- [x] Blocking validation errors prevent Continue/Process actions
- [x] Totals shown in preview match processed totals

## Done Criteria

- [x] Business user can complete end-to-end upload with a valid, simple template
- [x] Validation and error feedback are clear enough for non-technical users
- [x] Ownership behavior is enforced (uploader by default, admin override by authorization)
- [x] Process output is reusable for notification and reporting features
