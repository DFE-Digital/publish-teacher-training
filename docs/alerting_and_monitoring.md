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
