[Conventions](/guides/conventions.md) /

# Rails Architecture

This document describes the Rails conventions of this application.

## 1. File Structure

Learn more about each of the directories' purposes in the [File Structure](conventions/file-structure.md) guide.

```
.
└ app
  ├─ assets
  ├─ components (View Components)
  ├─ controllers
  ├─ forms (Form Objects)
  ├─ helpers
  ├─ javascript
  ├─ jobs
  ├─ lib
  ├─ mailers
  ├─ models
  ├─ policies
  ├─ serializers
  ├─ services (Service Objects)
  ├─ validators
  ├─ views
  └─ wizards
```

The following directories are deprecated and should be removed:

- `app/decorators`

  We should put decorator-type methods in models themselves.

- `app/view_objects`

  We should use View Components (`app/components`) instead.

## 2. Environments

There are 2 kinds of environments we need to maintain:

1. Rails environment (`RAILS_ENV`)

    There are 3 Rails environments:

    - `production`
    - `test`
    - `development`

2. Application environment (`APP_ENV`) - This is commonly known as Hosting environment in other BAT applications.

    This environment is used to determine the settings of the application.

    There are 5 Application environments:

    - `review`
    - `qa`
    - `staging`
    - `sandbox`
    - `production`

    The `loadtest` and `rollover` environments are deprecated and should be removed. We can use `staging` temporarily for these use-cases.
