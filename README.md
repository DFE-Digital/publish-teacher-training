[![Build Status](https://travis-ci.org/DFE-Digital/manage-courses-backend.svg?branch=master)](https://travis-ci.org/DFE-Digital/manage-courses-backend)

# Manage Courses Backend

## Prerequisites

- docker
- docker-compose

## Setting up the app in development

Run this in a shell and leave it running:

```
$ docker-compose up
```

The first time you run the app, you need to set up the databases. With the above command running separately, do:

```
$ docker-compose exec web /bin/sh -c "bundle exec rails db:setup"
```

Then open http://localhost:3000 to see the app.

## Accessing API

Example using the command line using the development basic authentication credentials:

```bash
curl --basic -u bat:beta http://localhost:3000/api/v1/subjects.json
```

## Linting

It's best to lint just your app directories and not those belonging to the framework, e.g.

```bash
$ docker-compose exec web /bin/sh -c "bundle exec govuk-lint-ruby app config db lib spec --format clang"
```
