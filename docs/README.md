# API Documentation

This directory contains the static documentation site for the Teacher Training Courses API. It is built with [Middleman](https://middlemanapp.com/) using the [govuk_tech_docs](https://github.com/alphagov/tech-docs-gem) gem.

The published docs are served at `/docs/` on the API host.

## How it all fits together

There are two systems that produce API documentation:

1. **rswag** (in the main Rails app) generates the OpenAPI spec (`swagger/public_v1/api_spec.json`) from RSpec tests in `spec/docs/`.
2. **Middleman** (this directory) builds a static HTML site that renders that OpenAPI spec alongside hand-written content pages.

```
spec/docs/*_spec.rb          # rswag test specs (define endpoints)
        |
        v
rake rswag:specs:swaggerize  # generates OpenAPI JSON
        |
        v
swagger/public_v1/
  api_spec.json               # generated OpenAPI 3.0 spec
  template.yml                 # base spec (info, servers, shared schemas)
  component_schemas/*.yml      # reusable schema definitions
        |
        v
docs/                          # Middleman site (this directory)
  source/*.html.md.erb         # content pages (the `api>` tag pulls in the spec)
  lib/govuk_tech_docs/open_api # custom renderer for OpenAPI
        |
        v
public/docs/                   # built static site, served by Rails
```

## Generating the OpenAPI spec

The OpenAPI spec is generated from the RSpec tests in `spec/docs/`. Run from the project root:

```sh
bundle exec rake rswag:specs:swaggerize
```

This runs the specs with `--dry-run` and `--format Rswag::Specs::SwaggerFormatter`, which extracts the parameter, response, and schema metadata and writes `swagger/public_v1/api_spec.json`.

The rake task is customised in `lib/tasks/swaggerize.rake` to only pick up files matching `spec/docs/**/*_spec.rb`.

### Writing rswag specs

Spec files live in `spec/docs/` and mirror the API's resource structure:

```
spec/docs/
  courses_spec.rb
  providers_spec.rb
  provider_suggestions_spec.rb
  subjects_spec.rb
  subject_areas_spec.rb
  providers/
    courses_spec.rb
    locations_spec.rb
    courses/
      locations_spec.rb
```

Each spec defines an API endpoint using the rswag DSL:

```ruby
require "swagger_helper"

describe "API" do
  path "/recruitment_cycles/{year}/providers" do
    get "Returns providers for the specified recruitment cycle." do
      operationId :public_api_v1_provider_index
      tags "provider"
      produces "application/json"

      parameter name: :year,
                in: :path,
                required: true,
                description: "The starting year of the recruitment cycle.",
                schema: { type: :string },
                example: "2025"

      curl_example description: "Get all providers",
                   command: "curl -X GET https://api.publish-teacher-training-courses.service.gov.uk/api/public/v1/recruitment_cycles/2025/providers"

      response "200", "Collection of providers." do
        schema({ "$ref" => "#/components/schemas/ProviderListResponse" })
        run_test!
      end
    end
  end
end
```

Key points:

- **Parameters**: Always put `type` inside the `schema` hash, not at the top level. rswag only auto-wraps `type` into `schema` when no `schema` key is present. If you specify both `type:` and `schema:` at the parameter level, `type` will leak into the generated JSON at the wrong level (invalid OpenAPI 3.0).

  ```ruby
  # Good - type inside schema
  parameter name: :include,
            in: :query,
            schema: { type: :string, enum: %w[provider recruitment_cycle] }

  # Good - schema with $ref (type comes from the referenced schema)
  parameter name: :filter,
            in: :query,
            schema: { "$ref" => "#/components/schemas/CourseFilter" },
            style: :deepObject

  # Good - type only, no schema (rswag wraps it automatically)
  parameter name: :year,
            in: :path,
            type: :string

  # Bad - type will appear at parameter level in the output
  parameter name: :include,
            in: :query,
            type: :string,
            schema: { enum: %w[provider] }
  ```

- **curl_example**: A custom extension (defined in `spec/swagger_helper.rb`) that adds `x-curl-examples` to the generated spec. The Middleman renderer displays these on the docs site.

- **Response schemas**: Use `$ref` to reference component schemas defined in `swagger/public_v1/component_schemas/`.

### Schema definitions

Reusable schemas live in two places:

- `swagger/public_v1/template.yml` - base template with the OpenAPI info block, servers, and shared structural schemas (e.g. `CourseResource`, `JSONAPI`, `Relationship`).
- `swagger/public_v1/component_schemas/*.yml` - individual YAML files for attribute schemas (e.g. `CourseAttributes.yml`, `ProviderFilter.yml`, `Pagination.yml`).

The `swagger_helper.rb` merges all component schemas into the template at load time, so you can `$ref` any schema from either location.

To add a new schema, create a YAML file in `component_schemas/` and reference it with `$ref: "#/components/schemas/YourSchemaName"`.

## Building the docs site

### Locally

```sh
cd docs
bundle install
bundle exec middleman server
```

Preview at http://localhost:4567. Changes to source files reload automatically; changes to `config/tech-docs.yml` require a restart.

To build the static output into the Rails `public/docs/` directory:

```sh
cd docs
bin/build
```

### In Docker / production

The Dockerfile has a `middleman` build stage that builds the docs site, then copies the output into `public/docs/` in the final Rails image. This happens automatically during the Docker build.

## Content pages

Source files are in `docs/source/` as `.html.md.erb` files (Markdown + ERB):

| File | Weight | Description |
|---|---|---|
| `index.html.md.erb` | 1 | About the API |
| `release-notes.html.md.erb` | 2 | Changelog / release notes |
| `api-reference.html.md.erb` | 3 | Full API reference (rendered from OpenAPI spec) |
| `specifications.html.md.erb` | 4 | Link to raw OpenAPI JSON |
| `support.html.md.erb` | 5 | Contact and feedback |

The `weight` frontmatter controls sidebar ordering.

The `api-reference.html.md.erb` page contains just `api>`, which is a special tag handled by the custom OpenAPI extension in `lib/govuk_tech_docs/open_api/`. It renders the full API reference from the OpenAPI spec.

## Running docs tests

The docs site has its own test suite for the OpenAPI renderer:

```sh
cd docs
bundle exec rspec
```

Tests are in `docs/spec/`.

## Common tasks

| Task | Command |
|---|---|
| Regenerate OpenAPI spec | `bundle exec rake rswag:specs:swaggerize` (from project root) |
| Preview docs locally | `cd docs && bundle exec middleman server` |
| Build docs for production | `cd docs && bin/build` |
| Run docs tests | `cd docs && bundle exec rspec` |
| Update release notes | Edit `docs/source/release-notes.html.md.erb` |
| Add a new endpoint | Create a spec in `spec/docs/`, regenerate the spec |
| Add a new schema | Create a YAML file in `swagger/public_v1/component_schemas/` |
