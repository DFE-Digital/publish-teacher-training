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

Feature flags are stored in Redis. The `FeatureFlag` class is a wrapper around the `Redis` class that provides a simple interface for setting and checking feature flags.

We want to move away from Redis and into a [Solid Cache](https://github.com/rails/solid_cache) backed approach.
