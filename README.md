# Find & Publish Teacher Training

[![View performance data on Skylight](https://badges.skylight.io/status/NXAwzyZjkp2m.svg)](https://oss.skylight.io/app/applications/NXAwzyZjkp2m)

This repo is home to three services:

- A service for candidates to [find teacher training](https://find-teacher-training-courses.service.gov.uk)
- A service for providers to [publish teacher training courses](https://www.publish-teacher-training-courses.service.gov.uk)
- An API to retrieve data on [teacher training courses](https://api.publish-teacher-training-courses.service.gov.uk)

## Environments

### Find

| Name        | URL                                                                     | Description
| ----------- | ----------------------------------------------------------------------- | ------------------------------------------------------------------------------
| Production  | [www](https://find-teacher-training-courses.service.gov.uk)             | Public site
| Staging     | [staging](https://staging.find-teacher-training-courses.service.gov.uk) | For internal use by DfE to test deploys
| QA          | [qa](https://qa.find-teacher-training-courses.service.gov.uk)           | For internal use by DfE for testing. Automatically deployed from main

### Publish

| Name        | URL                                                                        | Description
| ----------- | -------------------------------------------------------------------------- | ---------------------------------------------------------------------
| Production  | [www](https://www.publish-teacher-training-courses.service.gov.uk)         | Public site
| Staging     | [staging](https://staging.publish-teacher-training-courses.service.gov.uk) | For internal use by DfE to test deploys
| QA          | [qa](https://qa.publish-teacher-training-courses.service.gov.uk)           | For internal use by DfE for testing. Automatically deployed from main

## Guides

- [Configuration](/guides/configuration.md)
- [Machine Setup](/guides/machine-setup.md)
- [Setting up the application in development](/guides/setup-development.md)
- [Testing & Linting](/guides/testing.md)
- [Rollover](/guides/rollover.md)
- [API](/guides/api.md)
- [Authentication](/guides/authentication.md)
- [Alerting & Monitoring](/guides/alerting_and_monitoring.md)
- [Transactional Emails](/guides/emails.md)
- [Healthchecks](/guides/healthcheck_and_ping_endpoints.md)
- [Maintenance Mode](/guides/maintenance-mode.md)
- [Disaster Recovery Plan](/guides/disaster-recovery.md)
- [ADRs](/guides/adr/index.md)
- [Support Playbook](/guides/support_playbook.md)
- [AKS Module Information](/guides/aks_modules.md)
- [AKS Cheatsheet](/guides/aks-cheatsheet.md)
