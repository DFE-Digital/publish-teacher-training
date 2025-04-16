# Alerting and Monitoring

## External Integrations

### Skylight

skylight.io provides a rich set of performance monitoring tools, available form
on the apps [dashboard page](https://www.skylight.io/app/applications/NXAwzyZjkp2m).
Normally we enable skylight only in production.

#### Configuring in deployed environments

In a deployed environment, the environment variable
`SETTINGS__SKYLIGHT__AUTHENTICATION` should be set to the auth token available
from the application setting in skylight.io.

#### Configuring for local development

In local development, if you need to test performance monitoring you can enable
Skylight and set the auth token in a local settings file
`config/settings.local.yml`, with the token itself availble on the
[Skylight application setting page](https://www.skylight.io/app/settings/xRkb2HFQcwe7/app_settings)

```yaml
skylight:
  authentication: "auth_token_goes_here"
  enable: true
```

### Logit


We use `rails_semantic_logger` to collect our logs and send them to logit.io in every environment.

You can access Logit here https://dashboard.logit.io/

It is recommended to use email and password rather than SSO.


To learn more about how you can access the logs for our services watch this workshop recorded in 2024


#### Searching logs

| Field                     | Description                                    |
| ---                       | ---                                            |
| app.message               | Logging message                                |
| url.path                  | /publish/organisations/....                    |
| http.request.method       | GET                                            |
| kubernetes.container.name | publish-production/publish-review-1234         |
| app.tags                  | [session_id: "h34kj5h23j4h5..."]               |
| app.name                  |                                                |
| app.payload.params_json   | {provider_id: 1, recruitment_cycle_year: 2025} |


[Logging workshop](https://educationgovuk.sharepoint.com/:v:/r/sites/TeacherServices/Shared%20Documents/Learning/Logging%20workshop-20240918_160320-Meeting%20Recording.mp4?csf=1&web=1&e=wmf6XB&nav=eyJyZWZlcnJhbEluZm8iOnsicmVmZXJyYWxBcHAiOiJTdHJlYW1XZWJBcHAiLCJyZWZlcnJhbFZpZXciOiJTaGFyZURpYWxvZy1MaW5rIiwicmVmZXJyYWxBcHBQbGF0Zm9ybSI6IldlYiIsInJlZmVycmFsTW9kZSI6InZpZXcifX0%3D)

#### Logs in a review app

Choose your env

We are intersted in Production and Test (Development is for Infra testing)

https://dashboard.logit.io/a/7ef698e1-d0ae-46c6-8d1e-a1088f5e034e

