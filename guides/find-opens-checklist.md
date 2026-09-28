# Find opens checklist

Use this checklist on the morning Find opens. This checklist is for the 2026/2027 cycle.

## Before opening

- [ ] Get production [PIM access](https://portal.azure.com/?Microsoft_Azure_PIMCommon=true#view/Microsoft_Azure_PIMCommon/ActivationMenuBlade/~/aadgroup) approved and confirm it covers the monitoring window
- [ ] Check that you can access the production cluster/pods (Azure can be flakey and deny access even after a PIM request is approved)
- [ ] Activate **Hide subject knowledge enhancement content** in [production feature flags](https://www.publish-teacher-training-courses.service.gov.uk/support/feature-flags)
- [ ] Enable **Bursaries and scholarships announced** feature flag
- [ ] Verify both changes on Find
- [ ] Confirm access to [Logit](https://dashboard.logit.io/), Grafana, Azure and [Sentry](https://dfe-teacher-services.sentry.io/issues/?environment=production&project=1377944&statsPeriod=7d)
- [ ] Open the Teams monitoring and escalation [channel](https://teams.cloud.microsoft/l/channel/19%3Ad4ee3fa641fb4146961d2d727d92e77b%40thread.tacv2/REC%20Publish%20and%20Find%20System%20Notifications?groupId=5e035efe-5b2b-491b-9e3e-d832445e4ad1&tenantId=fad277c9-c60a-4da1-b5f3-b3b8b34a82f9)
- [ ] Confirm the expected production replica count by logging into the cluster and check deployment
- [ ] Check the production [`/healthcheck`](https://find-teacher-training-courses.service.gov.uk/healthcheck) is healthy
- [ ] Check the baseline traffic, response time and error rate
- [ ] Check for signs of imminent DDoS

## At opening

- [ ] Run a quick candidate journey:
  - [ ] Search and filters
  - [ ] Location search
  - [ ] Course and provider pages
  - [ ] Sign-in and saved courses, if relevant

## Monitor

- [ ] Logit logs ([Find dashboard](https://kibana-uk1.logit.io/s/e9b9162d-0b5e-4362-bed0-8e577f88d06e/app/dashboards#/view/e51bc1d0-8190-11ef-bdc9-dd9a0c20db74)) )
- [ ] [Grafana](https://grafana.teacherservices.cloud/goto/BkePpyXvg?orgId=1):
  - [ ] Request volume
  - [ ] Response times
  - [ ] Error rates
  - [ ] Pod CPU and memory
  - [ ] Pod restarts and health checks
  - [ ] Replica count
- [ ] [Azure Database](https://portal.azure.com/#@platform.education.gov.uk/resource/subscriptions/20da9d12-7ee1-42bb-b969-3fe9112964a7/resourceGroups/s189t01-ptt-stg-rg/providers/Microsoft.DBforPostgreSQL/flexibleServers/s189t01-ptt-stg-pg/overview):
  - [ ] Connections
  - [ ] CPU and memory
  - [ ] Slow or problematic queries
- [ ] [Worker Redis](https://portal.azure.com/#@platform.education.gov.uk/resource/subscriptions/3c033a0c-7a1c-4653-93cb-0f2a9f57a391/resourceGroups/s189p01-ptt-pd-rg/providers/Microsoft.Cache/Redis/s189p01-ptt-production-redis-worker/overview):
  - [ ] Memory usage
  - [ ] Connections
  - [ ] Errors and latency
- [ ] [Sentry exceptions](https://dfe-teacher-services.sentry.io/issues/?environment=production&project=1377944&statsPeriod=7d)
- [ ] [Teams and application alerts](https://teams.cloud.microsoft/l/channel/19%3Ad4ee3fa641fb4146961d2d727d92e77b%40thread.tacv2/REC%20Publish%20and%20Find%20System%20Notifications?groupId=5e035efe-5b2b-491b-9e3e-d832445e4ad1&tenantId=fad277c9-c60a-4da1-b5f3-b3b8b34a82f9)
- [ ] Candidate and support-reported issues

## If anything degrades

- [ ] Use the [Find Opens/DDoS escalation steps](../find-results-ddos-mitigations.md)
- [ ] Confirm who is leading the response
- [ ] Keep a brief note of any changes made
