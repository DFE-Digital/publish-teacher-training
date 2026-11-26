# AGENTS.md

Shared guidance for AI coding agents working in this repository. A person is responsible for every change an agent makes, so review and test what it produces. If this file and the code disagree, follow the code and fix this file.

More detail is in [guides/ai](guides/ai/README.md).

## The service

- Find teacher training courses (candidates), Publish teacher training courses (training providers), a Support console (DfE staff) and a public API used by Apply for teacher training and others. One Rails app with routes constrained by host.
- Ruby (version in `.ruby-version`), Rails 8.1, PostgreSQL with PostGIS, Pundit, discard, ViewComponent, govuk-components, the GOV.UK form builder and DfE Analytics.
- Background jobs run on Solid Queue and caching on Solid Cache. There is no Redis or Sidekiq.

## Commands

- Setup: `bin/setup`, then `bin/dev`. See [guides/setup-development.md](guides/setup-development.md).
- Tests: `bundle exec rspec`, or one file with `bundle exec rspec path/to/spec.rb`. Parallel: `bundle exec parallel_rspec`.
- Lint, as CI runs it: `bundle exec rubocop`, `bundle exec erb_lint app`, `bundle exec brakeman --quiet`, `yarn run standard`, `yarn run stylelint`, `yarn test`.

## Conventions

Follow the code around your change. The main patterns:

- **Authorisation:** Pundit. Publish and the API check every action with `after_action :verify_authorized`. Support is for admins only.
- **Services:** `include ServicePattern`, called as `Thing.call(...)`. Older services use `#execute`; match neighbouring code in those areas.
- **Forms:** new forms inherit `ApplicationForm`. Flows that keep state across steps use DfE::Wizard ([guides/wizards.md](guides/wizards.md)).
- **Soft delete:** Course, Provider and Site use discard. Query with `.kept`. Raw SQL must filter `discarded_at` itself.
- **Side effects:** run them after commit, usually through a job.
- **Jobs:** subclass `ApplicationJob` and choose the retry behaviour on purpose. Recurring jobs are in `config/recurring.yml`.
- **Feature flags:** `FeatureFlag.active?(:name)`, listed in `app/lib/feature_flags.rb`. For changes to what providers enter or candidates see, prefer gating on the recruitment cycle year over adding a flag.
- **Migrations:** schema changes in `db/migrate`, data changes in `db/data` (data_migrate). Add indexes concurrently. Table names are singular.
- **Copy:** user-facing text goes in locale files.
- **Tests:** unit specs for models, services, policies, jobs, forms and components; system specs for user journeys; request specs for the API. System specs find elements by visible text, not `data-qa` attributes. See [guides/conventions/testing.md](guides/conventions/testing.md).

## Before you finish

- Run the specs that cover your change and RuboCop on the Ruby files you changed.
- If you changed behaviour that a guide or ADR describes, update it.

## Do not, unless a person asks

- Commit, push, open pull requests or post comments on GitHub.
- Run commands against shared environments, such as `make` targets for QA, staging, sandbox or production, remote consoles, Terraform or the Azure CLI.
- Read, print or paste secrets, credentials or production data.
- Add gems or JavaScript packages.
- Mix schema changes and large data changes in one migration.

## Things that catch people out

These are explained in [guides/ai/known-traps.md](guides/ai/known-traps.md):

- Behaviour depends on the point in the recruitment cycle. Never hard-code the cycle year.
- Apply reads our public API. Check how it uses a field before changing it.
- New tables and columns need analytics, data-sanitising and diagram decisions.
- Schools live in `Provider::School` and `Course::School`. `Site` still holds study sites and older cycles.
- Rollover must be safe to run more than once.

## Personal preferences

Keep personal workflows, tool settings and credentials in your own user-level configuration, not in this repository.
