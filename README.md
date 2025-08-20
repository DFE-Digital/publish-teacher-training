# Publish & Find teacher training courses

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

## Developer documentation

### Getting Started

- [Developer onboarding](guides/developer-onboarding.md)
- [Setting up your local environment](guides/setup-development.md)
- [Development workflow](guides/development-workflow.md)
- [Conventions](guides/conventions.md)

### Guides

- [Prototype branches](guides/prototype-branches.md)
- [Support playbook](guides/support-playbook.md)
- [Authentication](guides/authentication.md)
- [API](guides/api.md)
- [Monitoring](guides/monitoring.md)
- [Healthchecks](guides/healthchecks.md)
- [Rollover](guides/rollover.md)

### Infrastructure

- [AKS Module Information](guides/aks-modules.md)
- [AKS Cheatsheet](guides/aks-cheatsheet.md)

