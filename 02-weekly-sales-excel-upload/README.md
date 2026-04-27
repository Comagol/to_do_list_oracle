# 02 - Weekly Sales Excel Upload

## Objective

Create an APEX app flow that lets users download an Excel template, upload completed data, preview parsed rows, validate, and process with a summary result page.

## Business Scenario

Use **Weekly Sales Operations**:

- Store supervisors submit weekly sales by category
- Regional managers review totals and exceptions
- Finance consumes clean monthly aggregates

## Core Flow

1. User downloads current template
2. User uploads file into `APEX_APPLICATION_TEMP_FILES` (`apex_flow_files`)
3. System parses rows in memory and shows preview
4. User clicks Continue to execute validations
5. System persists valid rows and shows summary (valid/invalid totals)

## Example Template Columns

- `week_start`
- `store_code`
- `product_category`
- `units_sold`
- `gross_sales`

## Deliverables

- Template generation/download page
- Upload and parse process
- Preview report region
- Validation framework
- Processing summary page
