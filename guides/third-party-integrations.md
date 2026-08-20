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

| Service                                | Purpose                          | Integration             |
|----------------------------------------|----------------------------------|-------------------------|
| Google BigQuery                        | Web analytics                    | Via `dfe-analytics` gem |
| [Airbyte](../terraform/aks/airbyte.tf) | Database replication to BigQuery | Configured in Terraform |
| [Google Geocoding API](geolocation.md) | Location search on Find          | REST API                |

## Monitoring and Observability

| Service                                      | Purpose                            | Integration                             |
|----------------------------------------------|------------------------------------|-----------------------------------------|
| [Sentry](monitoring.md)                      | Error tracking                     | Via `sentry-ruby` / `sentry-rails` gems |
| [Skylight](monitoring.md)                    | Application performance monitoring | Via `skylight` gem                      |
| [Logit.io](monitoring.md)                    | Centralised logging                | Via `rails_semantic_logger`             |
| [StatusCake](../terraform/aks/statuscake.tf) | Uptime monitoring                  | Configured in Terraform                 |

## Code Quality

| Service     | Purpose               | Integration        |
|-------------|-----------------------|--------------------|
| CodeClimate | Code quality analysis | GitHub integration |
