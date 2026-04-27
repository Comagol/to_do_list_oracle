# Plan

## Phase 1 - Setup

- Install/configure Oracle APEX Office Print integration
- Create secure credentials and environment variables
- Validate basic sample print works

## Phase 2 - Data Preparation

- Reuse the existing Sales app data model and queries as source of truth
- Build monthly aggregation query from weekly sales table
- Add dimensions for sales rep, store, product, category, and period
- Include KPI calculations (growth, average ticket, totals, units sold)

## Phase 3 - Multi-Report Definition (AOP)

- Implement **3 different printable reports** from the Sales app:
- Report 1: **Monthly Sales Summary by Rep**
- Report 2: **Total Products Sold** report with chart + detailed table
- Report 3 (proposed): **Top Stores and Risk Stores** report showing:
  - Top N stores by sales amount
  - Stores with sharp month-over-month decline
  - Suggested follow-up priority for sales leadership
- Define shared filters for all reports (month/year, optional region/store)
- Define each report output format (PDF required, optional Excel where needed)

## Phase 4 - Template Design and Branding

- Create dedicated AOP templates for each of the 3 reports
- Add required company logo in template header area
- Add a specific standardized header (company, report name, period, generation date)
- Keep consistent footer metadata (user, generated timestamp, page number)
- Ensure at least one chart and one detailed table in product-focused report

## Phase 5 - APEX Integration

- Add print actions/buttons in Sales app for all 3 report types
- Route each action to the correct AOP template and data source
- Generate PDF output and stream/download result
- Optionally generate Excel output for analysts where tabular detail is needed

## Phase 6 - Quality and Performance

- Validate report data consistency against Sales app dashboard totals
- Validate all three reports with at least 3 different monthly periods
- Test larger data volumes for generation time
- Validate role-based access (only authorized users can print)
- Document template update process (logo/header updates without code rewrites)
