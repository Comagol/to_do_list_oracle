# Checklist

## Build Checklist

- [ ] Five notification methods are modeled and configurable
- [ ] Admin can enable/disable methods per notification type
- [ ] Config page includes connection settings and test button
- [ ] Automatic methods (email/in-app/push) run without extra server setup
- [ ] WhatsApp and SMS require and validate server configuration
- [ ] Sales file processing completion triggers notification dispatch

## Validation Checklist

- [ ] Test button sends expected sample payload
- [ ] Failed deliveries are logged with reason
- [ ] Retries do not duplicate successful sends
- [ ] Notification includes uploaded totals from processed file

## Done Criteria

- [ ] End-to-end notification flow works from sales upload event
- [ ] Admin can operate feature without code changes
- [ ] Monitoring view exists for delivery status
