# Alerting and Monitoring

## External Integrations

### Sentry

[sentry.io](https://docs.sentry.io/platforms/ruby/) now includes performance monitoring tools, available
on the apps [Performance tab](https://sentry.io/organizations/dfe-bat/performance/?project=1377944).
Normally we enable performance monitoring only in production, by setting `traces_sample_rate` in the sentry initializer.

#### Configuring in deployed environments

In a deployed environment, the environment variable
`SENTRY_DSN` should be set to the value of the Sentry DSN, available under
Settings -> Application Name -> Client Keys (DSN)

#### Configuring for local development

In local development, if you need to test performance monitoring you can enable
Sentry by providing a `SENTRY_DSN` environment variable. In the Sentry dashboard, one can filter the performance metrics by environment (i.e: development).
