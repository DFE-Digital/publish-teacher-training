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

[Logging workshop](https://educationgovuk.sharepoint.com/:v:/r/sites/TeacherServices/Shared%20Documents/Learning/Logging%20workshop-20240918_160320-Meeting%20Recording.mp4?csf=1&web=1&e=wmf6XB&nav=eyJyZWZlcnJhbEluZm8iOnsicmVmZXJyYWxBcHAiOiJTdHJlYW1XZWJBcHAiLCJyZWZlcnJhbFZpZXciOiJTaGFyZURpYWxvZy1MaW5rIiwicmVmZXJyYWxBcHBQbGF0Zm9ybSI6IldlYiIsInJlZmVycmFsTW9kZSI6InZpZXcifX0%3D)
