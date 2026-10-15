# Configuration

This repo is configured using a file based settings approach via the [config gem](https://github.com/railsconfig/config#accessing-the-settings-object) (see `config/settings.yml` for an example).

## Settings vs Environment variables

Refer to the [the config gem](https://github.com/railsconfig/config#accessing-the-settings-object) to understand the `file based settings` loading order.

To override file based via `Machine based env variables settings`

```bash
cat config/settings.yml
file
  based
    settings
      env1: 'some file based value'
```

```bash
export SETTINGS__FILE__BASED__SETTINGS__ENV1="machine wins"
```

```ruby
puts Settings.file.based.setting.env1

machine wins
```

Any `Machine based env variables settings` that is not prefixed with `SETTINGS`.\* are not considered for general consumption.

## Feature Flags

Feature flags are stored in the `feature_flag_state` Postgres table and accessed
through `FeatureFlag`. Reads are memoised on `Current` for the request.

While an older release remains deployable, changes are also mirrored to the
worker Redis for rollback. See
[Application state off Redis](../redis-application-state.md).
