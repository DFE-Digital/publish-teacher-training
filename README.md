
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

### Settings

If you are going to login with a user who hasn't recieved the welcome email - you will need to set the following settings to their correct values in `config/settings/development.local.yml`:

- `govuk_notify.api_key`
- `govuk_notify.welcome_email_template_id`

### Native

0. If you haven't already, follow this [tutorial](https://gorails.com/setup) to setup your Rails environment, make sure to install PostgreSQL 9.6 as the database
1. Run `bundle install` to install the gem dependencies.
2. Run `bundle exec rails db:setup` to create a development and testing database.
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


## Running specs
```
bundle exec rspec
```

Or through guard (`--no-interactions` allows the use of `pry` inside tests):

```bash
bundle exec guard --no-interactions
```

## Architectural Decision Record

See the [docs/adr](docs/adr) directory for a list of the Architectural Decision
Record (ADR). We use [adr-tools](https://github.com/npryce/adr-tools) to manage
our ADRs, see the link for how to install (hint: `brew install adr-tools` or use
ASDF).

## Running specs in parallel

When running specs in parallel for the first time you will first need to set up
your test databases.

`bundle exec rails parallel:setup`

To run the specs in parallel:
`bundle exec rails parallel:spec`

To drop the test databases:
`bundle exec rails parallel:drop`

## Linting

It's best to lint just your app directories and not those belonging to the framework:

```bash
bundle exec rubocop app config db lib spec --format clang

or

docker-compose exec web /bin/sh -c "bundle exec rubocop app config db lib spec Gemfile --format clang"
```

## Running specs, linter (with auto correct) and annotate models and serializers

```
bundle exec rake
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

In order to use the external environment functionality you must set the
environments in ```config/azure_environments.yml ```like so:  
```
qa:
    webapp: <webapp>
    rgroup: <rgroup>
    subscription: <subscription>
staging:
  webapp: <webapp>
  rgroup: <rgroup>
  subscription: <subscription>
production:
  webapp: <webapp>
  rgroup: <rgroup>
  subscription: <subscription>
```
If you are a member of the Find team you may find a filled out config [here](https://dfedigital.atlassian.net/wiki/spaces/BaT/pages/1182761062/MCB+Configuration?atlOrigin=eyJpIjoiZDg0N2Q2ZTg0NTRiNDQ1MmEwZWQ3M2VhZjMyYjIxNjEiLCJwIjoiYyJ9n).

The script's functionality is accessed using sub-commands with built-in
documentation. This is the best way to discover it's functionality and the
commands available, and is accessible with the `--help` option:

```
bin/mcb --help
or
bin/mcb -h
```

Commands for mcb are defined in `lib/mcb/commands` and any new commands should
be organised in an appropriate sub-folder there.

### Dependencies

* Requires an installation of the `az` command on the `PATH`. Get it at
  https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest
* An Azure account with access to the subscription(s) - if you're on a non-DfE
  device you need BYOD & 2FA set up.
* A publish user with your email address with access to the organisation(s) you
  want to modify.

### Mandatory requirements

To successfully log into the system, you will need to:
1. Create an account on DfE Sign-in
   1. Get a DfE Sign-in admin to invite you (give them this link:
      https://signin-test-sup-as.azurewebsites.net/users)
   2. Sign up from the email sent from DfE Sign-in
2. Grant access to some providers:
   1. For local: `bundle exec bin/mcb users grant {email} {provider_code}`
   2. For `qa` and `production`:
      1. You will need to log into Azure first: `az login`
      2. `bundle exec bin/mcb -E {env} users grant {email} {provider_code}`

Users not matching
`%@digital.education.gov.uk` and `%@education.gov.uk`
will be anonymized for non production environment.

## Using services

[See the services README](./app/services/README.md)


## <a name="releases"></a>Releases

Find (Manage-Courses) build and release process is split into two separate Azure DevOps pipelines.
- [Build Pipeline](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build?definitionId=46): This is the main development CI pipeline which will automatically trigger a build from a commit to any branch within the manage-courses-backend GitHub code repository. 
- [Release Pipeline](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_release?_a=releases&view=mine&definitionId=36): When commits are made to the master branch, this pipeline will auto deploy the application to the QA infrastructure environment in Azure. Frontend and backend release pipelines are consolidated and are made up of several stages including integration testing. Release in staging and production can be triggered manualy only - see deployment guide for more details.

### <a name="releases-triggering"></a>Deploying

👉 [See the deployment guide](/docs/deployment.md)