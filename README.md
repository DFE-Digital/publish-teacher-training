[![Build Status](https://travis-ci.org/DFE-Digital/manage-courses-backend.svg?branch=master)](https://travis-ci.org/DFE-Digital/manage-courses-backend)

# Manage Courses Backend

## Prerequisites

- docker
- docker-compose

## Setting up the app in development

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

Then open http://localhost:3000 to see the app.

## Setting up the app for local (non-Docker) development

### Installing prerequisites

On Linux:

```bash
sudo apt install postgresql-9.6 postgresql-contrib-9.6
```

### Creating the DB user

Before creating the db create the dev user:

```bash
rails db:create_dev_user
```

## Accessing API

[See API Docs](https://github.com/DFE-Digital/manage-courses-backend/blob/master/docs/api.md)

## Linting

It's best to lint just your app directories and not those belonging to the framework:

```bash
docker-compose exec web /bin/sh -c "bundle exec govuk-lint-ruby app config db lib spec --format clang"
```

## CI variables

You'll need to define the `AZURE_CR_PASSWORD` in Travis in order to successfully build and publish. This can be done using this command:

```bash
travis encrypt AZURE_CR_PASSWORD="xxx" --add
```
