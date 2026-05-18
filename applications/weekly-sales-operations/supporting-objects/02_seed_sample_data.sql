-- ============================================================
-- Weekly Sales Operations — Sample seed data
-- ============================================================

MERGE INTO poc_app_settings t
USING (
    SELECT 'COMPANY_NAME' AS setting_key,
           q'[comagol's factory]' AS setting_value
      FROM dual
) s
ON (t.setting_key = s.setting_key)
WHEN MATCHED THEN
    UPDATE SET t.setting_value = s.setting_value,
               t.updated_at = SYSTIMESTAMP
WHEN NOT MATCHED THEN
    INSERT (setting_key, setting_value)
    VALUES (s.setting_key, s.setting_value);

MERGE INTO poc_stores t
USING (
    SELECT 'ST001' AS store_code, 'North Plaza' AS store_name, 'NORTH' AS region_code FROM dual UNION ALL
    SELECT 'ST002', 'South Market', 'SOUTH' FROM dual UNION ALL
    SELECT 'ST003', 'East Corner', 'EAST' FROM dual
) s
ON (t.store_code = s.store_code)
WHEN NOT MATCHED THEN
    INSERT (store_code, store_name, region_code)
    VALUES (s.store_code, s.store_name, s.region_code);

MERGE INTO poc_product_categories t
USING (
    SELECT 'ELECTRONICS' AS category_code, 'Electronics' AS display_name, 10 AS sort_order FROM dual UNION ALL
    SELECT 'GROCERY', 'Grocery', 20 FROM dual UNION ALL
    SELECT 'CLOTHING', 'Clothing', 30 FROM dual UNION ALL
    SELECT 'HOME', 'Home', 40 FROM dual
) s
ON (t.category_code = s.category_code)
WHEN NOT MATCHED THEN
    INSERT (category_code, display_name, sort_order)
    VALUES (s.category_code, s.display_name, s.sort_order);

MERGE INTO poc_sales_reps t
USING (
    SELECT 'REP_NORTH' AS rep_code, 'North Team Lead' AS display_name, 'NORTH' AS region_code FROM dual UNION ALL
    SELECT 'REP_SOUTH', 'South Team Lead', 'SOUTH' FROM dual UNION ALL
    SELECT 'REP_EAST', 'East Team Lead', 'EAST' FROM dual
) s
ON (t.rep_code = s.rep_code)
WHEN NOT MATCHED THEN
    INSERT (rep_code, display_name, region_code)
    VALUES (s.rep_code, s.display_name, s.region_code);

COMMIT;
