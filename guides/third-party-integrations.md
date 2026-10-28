# Third-Party Integrations

A register of all third-party services used by Publish and Find. Connection credentials are stored in Azure Key Vault
and configured during developer onboarding. Infrastructure-level integrations are managed by the DfE infrastructure
team. SLAs and renewal dates are managed centrally by DfE.

## Authentication

| Service                          | Purpose                                            | Integration      |
|----------------------------------|----------------------------------------------------|------------------|
| [GOV.UK One Login](one-login.md) | Candidate authentication (Find)                    | OAuth 2.0 / OIDC |
| [DfE Sign-in](authentication.md) | Provider and support user authentication (Publish) | OIDC             |

## Notifications

| Service       | Purpose                     | Integration                                  |
|---------------|-----------------------------|----------------------------------------------|
| GOV.UK Notify | Email and SMS notifications | REST API via `notifications-ruby-client` gem |

## Data and Analytics

| Service                                | Purpose                          | Integration                               |
|----------------------------------------|----------------------------------|-------------------------------------------|
| Google BigQuery                        | Web analytics                    | Via `dfe-analytics` gem                   |
| [Airbyte](../terraform/aks/airbyte.tf) | Database replication to BigQuery | Configured in Terraform                   |
| [Google Geocoding API](geolocation.md) | Location search on Find          | REST API                                  |
| GIAS (Get Information About Schools)   | School data import               | Daily CSV download via `Gias::Downloader` |

The GIAS import runs daily as `GiasImportJob` on Solid Queue, scheduled by `config/recurring.yml`. The job downloads the full school dataset
from the Edubase API, transforms it, and upserts records into the `gias_school` table. Provider schools and course
location searches depend on this data. See `lib/gias/` for the download, transform, and import pipeline.

## API catalogue

| Service                                                                                                              | Purpose                                     | Integration                            |
|----------------------------------------------------------------------------------------------------------------------|---------------------------------------------|----------------------------------------|
| [Find and use an API](https://tech-docs.teacherservices.cloud/documenting-an-api/documenting-sd-apis-in-fauapi.html) | Lists the public API in DfE's API catalogue | REST API via `FindAndUseAnAPI::Client` |

`FindAndUseAnAPI::PublishCatalogueJob` runs daily on Solid Queue, scheduled by `config/recurring.yml`. It imports
`config/fauapi/manifest.json` with `swagger/public_v1/api_spec.json` inline, then publishes the entry. Staging publishes
to the pre-prod portal and production to the live one, each with its own workspace token in `SETTINGS__FAUAPI__API_KEY`;
`Settings.fauapi.enabled` gates the job. The portal stores `name` as `displayName` in kebab case, so keep the two in
step: the job finds the entry to publish by `name` and `majorVersion`, and fails without publishing if nothing matches.

## Monitoring and Observability

| Service                                      | Purpose                            | Integration                             |
|----------------------------------------------|------------------------------------|-----------------------------------------|
| [Sentry](monitoring.md)                      | Error tracking                     | Via `sentry-ruby` / `sentry-rails` gems |
| [Skylight](monitoring.md)                    | Application performance monitoring | Via `skylight` gem                      |
| [Logit.io](monitoring.md)                    | Centralised logging                | Via `rails_semantic_logger`             |
| [StatusCake](../terraform/aks/statuscake.tf) | Uptime monitoring                  | Configured in Terraform                 |

## Code Quality

| Service     | Purpose               | Integration        | Status       |
|-------------|-----------------------|--------------------|--------------|
| CodeClimate | Code quality analysis | GitHub integration | **Inactive** |
