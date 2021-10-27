[![Build Status](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_apis/build/status/Find/teacher-training-api?branchName=master)](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build/latest?definitionId=46&branchName=master)
![Build](https://github.com/DFE-Digital/teacher-training-api/workflows/Build/badge.svg?branch=master&event=push)
[![Maintainability](https://api.codeclimate.com/v1/badges/b97c086ada58c27c967c/maintainability)](https://codeclimate.com/github/DFE-Digital/teacher-training-api/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/b97c086ada58c27c967c/test_coverage)](https://codeclimate.com/github/DFE-Digital/teacher-training-api/test_coverage)
[![View performance data on Skylight](https://badges.skylight.io/status/NXAwzyZjkp2m.svg?token=JaYZey50Y8gfC00RvzkcrDz5OP-SwiBSTtbhkMw1KIs)](https://www.skylight.io/app/applications/NXAwzyZjkp2m)

# Teacher Training API

## Prerequisites

### Native

- PostgreSQL 11
- GraphViz

### Docker

- docker
- docker-compose

## Setting up the app in development

### Native

#### Install build dependencies

Install [asdf-vm](https://asdf-vm.com/).

Install the plugins and versions specified in `.tool-versions`

```bash
asdf plugin add ruby
asdf plugin add nodejs
asdf plugin add yarn
asdf install
```

When the versions are updated in master run `asdf install` again to update your
installation.

(We don't mandate asdf, you can use other tools if you prefer.)

#### Run the builds

Run the following commands:

```bash
yarn
bundle
bundle exec rake webpacker:compile
bundle exec rails db:setup
```

#### Run the server

```bash
bundle exec rails server
```

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

### Run The Server in SSL Mode

By default the server does not run in SSL mode. If you want to run the local
server in SSL mode, you can do so by setting the environment variable
`SETTINGS__USE_SSL`, for example, use this command to run the server:

```bash
SETTINGS__USE_SSL=1 rails s
```

### Trust the TLS certificate

Depending on your browser you may need to add the automatically generated SSL
certificate to your OS keychain to make the browser trust the local site.

On macOS:

```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain config/localhost/https/localhost.crt
```

## Running specs

```
bundle exec rspec
```

Or through guard (`--no-interactions` allows the use of `pry` inside tests):

```bash
bundle exec guard --no-interactions
```

### Running specs in parallel

When running specs in parallel for the first time you will first need to set up
your test databases.

`bundle exec rails parallel:setup`

To run the specs in parallel:
`bundle exec rails parallel:spec`

To drop the test databases:
`bundle exec rails parallel:drop`


## Architectural Decision Record

See the [docs/adr](docs/adr) directory for a list of the Architectural Decision
Record (ADR). We use [adr-tools](https://github.com/npryce/adr-tools) to manage
our ADRs, see the link for how to install (hint: `brew install adr-tools` or use
ASDF).

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

### V2

#### Authentication

Authenticating with V2 of the API relies on an email address of an existing user
in the database being supplied as the bearer token.

An example HTTP request would look like:

```
GET /api/v2/recruitment_cycles.json
Authorization: Bearer <encoded JWT token>
```

or with curl:

```bash
curl http://localhost:3001/api/v2/recruitment_cycles.json -H "Authorization: Bearer <encoded JWT token>"
```

Encoding the payload can be done with an MCB command:

```
$ bin/mcb apiv2 token generate -S sekret --audience audience --issuer issuer --subject subject user@example.com
eyJhbGciOiJIUzI1NiJ9.eyJkYXRhIjp7ImVtYWlsIjoidXNlckBsb2NhbF0ifSwiYXVkIjoiYXVkaWVuY2UiLCJleHAiOjE2MDU1NTg1OTQsImlhdCI6MTYwNTU1ODI5NCwiaXNzIjoiaXNzdWVyIiwic3ViIjoic3ViamVjdCJ9.81jNfeJGBLpgB64TD60oMc3UOkQtSjnQRRPUwEiQCXo
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

Any `Machine based env variables settings` that is not prefixed with `SETTINGS`.\* are not considered for general consumption.

### Documentation

Use the following command to generate OpenAPI specification:

```sh
bundle exec rake rswag:specs:swaggerize
```

We use [Tech Docs](https://github.com/alphagov/tech-docs-gem) to build documentation. To update documentation, the relevant files can be found in `/docs`. The docker build will then take these files to generate the static site.

To develop and preview the tech docs you can start and run with [Middleman](https://github.com/middleman/middleman)

```sh
cd docs && bundle install && bundle exec middleman
```

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
environments in `config/azure_environments.yml `like so:

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

- Requires an installation of the `az` command on the `PATH`. Get it at
  https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest
- An Azure account with access to the subscription(s) - if you're on a non-DfE
  device you need BYOD & 2FA set up.
- A publish user with your email address with access to the organisation(s) you
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

## <a name="releases"></a>Releases

Find (Publish Teacher Training & Teacher Training API) build and release process is split into two separate Azure DevOps pipelines.

- [Build Pipeline](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build?definitionId=46): This is the main development CI pipeline which will automatically trigger a build from a commit to any branch within the teacher-training-api GitHub code repository.
- [Release Pipeline](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_release?_a=releases&view=mine&definitionId=36): When commits are made to the master branch, this pipeline will auto deploy the application to the QA infrastructure environment in Azure. Frontend and backend release pipelines are consolidated and are made up of several stages including integration testing. Release in staging and production can be triggered manualy only - see deployment guide for more details.

## <a name="other_documentation"></a>Other Documentation

- [Deployment guide](./docs/deployment.md)
- [Services pattern documentation](./app/services/README.md)
- [Healthcheck and Ping Endpoints](./docs/healthcheck_and_ping_endpoints.md)
- [Alerting and monitoring](./docs/alerting_and_monitoring.md)
