[![Build Status](https://travis-ci.org/DFE-Digital/manage-courses-backend.svg?branch=master)](https://travis-ci.org/DFE-Digital/manage-courses-backend)

# Manage Courses Backend

## Prerequisites

- Ruby 2.5.3

## Setting up the app in development

1. Run `bundle install` to install the gem dependencies
2. Run `rails db:setup` to create a development and testing database
3. Run `bundle exec rails server` to launch the app on http://localhost:3000.

## Accessing API

Example using the command line using the development basic authentication credentials

```bash
curl --basic -u bat:beta http://localhost:3000/api/v1/subjects.json
```

## Linting

It's best to lint just your app directories and not those belonging to the framework, e.g.

```bash
bundle exec govuk-lint-ruby app config db lib spec --format clang
```
