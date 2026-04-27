# Checklist

## Build Checklist

- [x] AOP integration is configured and reachable
- [x] Monthly sales data source from existing Sales app is complete and accurate
- [x] Report 1 (Summary by Rep) query and template are implemented
- [x] Report 2 (Total Products Sold) query and template are implemented
- [x] Report 2 includes chart and product detail table
- [x] Report 3 (Top Stores and Risk Stores) query and template are implemented
- [ ] AOP templates include required company logo
- [ ] AOP templates include the specific standardized header (company/report/period/date)
- [x] Print actions are available in the Sales app for all 3 reports
- [x] PDF output is generated successfully

## Validation Checklist

- [x] Generated totals match source monthly aggregates
- [x] Summary by Rep totals match Sales app totals per rep
- [x] Product totals match source product sales aggregates
- [x] Chart values match report tables
- [x] Top stores and risk stores logic is correct and traceable
- [ ] Output works for at least 3 different months

## Done Criteria

- [ ] Three monthly printable reports are production-ready
- [ ] Templates (logo/header/footer) can be updated without PL/SQL rewrites
- [ ] Business users can consume output without manual edits
