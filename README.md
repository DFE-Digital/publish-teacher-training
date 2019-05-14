[![Build Status](https://travis-ci.org/DFE-Digital/manage-courses-backend.svg?branch=master)](https://travis-ci.org/DFE-Digital/manage-courses-backend)
[![Build Status](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_apis/build/status/Find/manage-courses-backend?branchName=master)](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build/latest?definitionId=46&branchName=master)
[![Maintainability](https://api.codeclimate.com/v1/badges/a45d9506b9c0e3f0fd8f/maintainability)](https://codeclimate.com/github/DFE-Digital/manage-courses-backend/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/a45d9506b9c0e3f0fd8f/test_coverage)](https://codeclimate.com/github/DFE-Digital/manage-courses-backend/test_coverage)

# Manage Courses Backend

## Prerequisites

### Native

- Ruby 2.6.1
- postgresql-9.6 postgresql-contrib-9.6

### Docker

- docker
- docker-compose

## Setting up the app in development

### Native

1. Run `bundle install` to install the gem dependencies
2. Run `bundle exec rails db:setup` to create a development and testing database
3. Run `bundle exec rails server` to launch the app on http://localhost:3001.

### Docker

Run this in a shell and leave it running:

```
docker-compose up --build --detach
```

You can then follow the log output with

```
docker-compose logs --follow
```

The first time you run the app, you need to set up the databases. With the above command running separately, do:

```
docker-compose exec web /bin/sh -c "bundle exec rails db:setup"
```

Then open http://localhost:3001 to see the app.

## Running specs, linter(without auto correct) and annotate models and serializers
```
bundle exec rake
```

## Running specs
```
bundle exec rspec
```

Or through guard (`--no-interactions` allows the use of `pry` inside tests):

```bash
bundle exec guard --no-interactions
```

## Linting

It's best to lint just your app directories and not those belonging to the framework:

```bash
bundle exec rubocop app config db lib spec --format clang

or

docker-compose exec web /bin/sh -c "bundle exec rubocop app config db lib spec Gemfile --format clang"
```

## Accessing API

### V1

[See API Docs](https://github.com/DFE-Digital/manage-courses-backend/blob/master/docs/api.md)

Quick check that it's working in local development with the token "bats"
configured in `config/environments/development.rb`:

```bash
curl http://localhost:3001/api/v1/2019/subjects.json -H "Authorization: Bearer bats"
```

### V2

#### Authentication

Authenticating with V2 of the API relies on an email address of an existing user
in the database being supplied as the bearer token.

An example HTTP request would look like:

```
GET /api/v2/providers.json
Authorization: Bearer <encoded JWT token>
```

or with curl:

```bash
curl http://localhost:3001/api/v2/providers.json -H "Authorization: Bearer <encoded JWT token>"
```

Encoding the payload can be done with an MCB command:

```
$ bin/mcb apiv2 token generate -S secret user@example.com
eyJhbGciOiJIUzI1NiJ9.IntcImVtYWlsXCI6XCJ1c2VyQGV4YW1wbGUuY29tXCJ9Ig.f9kNofCO0u35B01AUht1cJ472YSDjaol_iKScYuVux4
```

Where `-S secret` is the secret. In development, the secret should be set to
`secret` by default on backend and frontend.

## Settings vs config vs Environment variables

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

Any `Machine based env variables settings` that is not prefixed with `SETTINGS`.* are not considered for general consumption.



## CI variables

You'll need to define the `AZURE_CR_PASSWORD` in Travis in order to successfully build and publish. This can be done using this command:

```bash
travis encrypt AZURE_CR_PASSWORD="xxx" --add
```

## Sentry

To track exceptions through Sentry, configure the `SENTRY_DSN` environment variable:

```
SENTRY_DSN=https://aaa:bbb@sentry.io/123 rails s
```

## mcb Command

This project comes with a script `bin/mcb` which provides certain
project-specific functionality that is conveniently accessed via the cmdline.
The goal is to provide access to project data and functionality in a guided
way that is safer and better sign-posted than using the raw Rails console. This
can be useful for people who aren't as familiar with the app, or with certain
complex operations that just aren't already packaged up in the app.

The script's functionality is accessed using sub-commands with built-in
documentation. This is the best way to discover it's functionality and the
commands available, and is accessable with the `--help` option:

```
bin/mcb --help
or
bin/mcb -h
```

Commands for mcb are defined in `lib/mcb/commands` and any new commands should
be organised in an appropriate sub-folder there.
