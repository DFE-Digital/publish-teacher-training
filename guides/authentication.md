# Authentication

## Find

The Find service is publicly available with one or two internal routes protected by basic auth.

### Basic Auth

The feature flags route in Find is protected by basic auth. The username and password are set in the `SETTINGS__BASIC_AUTH_USERNAME` and `SETTINGS__BASIC_AUTH_PASSWORD` environment variables.

## Publish

### Basic Auth

The Publish QA environment is protected by basic auth. The username and password can be provided by a Find/Publish team member.

### DfE Sign in

To access the staging and production environments, you will need to sign in with DfE Sign-in.

### Magic Link Sign in

In the event that DfE Sign-in is unavailable, we enable sign in via magic link. This needs to be enabled in the `config/settings.yml` file.

```
authentication:
  mode: magic_link
```

## API

The API is public and does not require authentication.
