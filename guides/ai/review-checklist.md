# Review checklist

What to check when reviewing a change to this repository, whether a person or an agent is doing the review. It comes from the points reviewers have raised most often. The reasons behind many of them are in [known-traps.md](known-traps.md).

## How to review

1. Read the whole diff and the code around it before commenting. Compare with similar code in the same area.
2. Read the guides or ADRs for the areas the diff touches.
3. Report only things that should change. Don't list checks that passed or praise correct code. If nothing needs changing, say "No blocking or recommended changes."
4. Don't edit files or post to GitHub during a review unless asked.

## What to check

### Authorisation and security

- New Publish actions are authorised with Pundit, and records are looked up through the signed-in user or provider rather than raw ids from params. The public API allows anonymous reads on purpose, so don't ask for sign-in or ownership checks there.
- Controllers that skip authentication or authorisation name the actions in `only:`.
- Redirects to a URL from params or the session use an allow-list and reject protocol-relative URLs (`//example.com`).
- GET requests don't change business data. Deliberate usage and history writes are fine, such as recording API key use or a candidate's recent searches.
- No `html_safe` or `raw` on text that could contain user input. User text placed in GOV.UK Notify emails is sanitised.
- If the code rescues an exception, it still reports it to Sentry. Prefer services that return a result over exceptions for normal outcomes.

### Data, migrations and analytics

- Schema changes in `db/migrate` and data changes in `db/data`, never both in one migration.
- Indexes on existing tables are added concurrently. Before a new unique index, the existing data has been checked for duplicates.
- Columns are removed in two steps: ignore the column first, then drop it in a later release. Saved Blazer queries that use the column are updated.
- New tables and columns are listed in `config/analytics.yml` or `config/analytics_blocklist.yml`. Personal data is in `config/analytics_hidden_pii.yml`, emptied in `db/scripts/sanitise.sql`, and considered for the Airbyte stream config. `docs/database-diagram.mmd` is updated.
- Free text, emails, names or precise locations aren't sent to analytics, logs or job arguments without a reason.
- Bulk `update_all` or `delete_all` calls account for the callbacks and validations they skip.

### Public API

- Changes to what the API returns have been checked against how Apply uses it, especially `findable`, location UUIDs and course status fields.
- Changes that alter a course's API response also update its `changed_at`.
- The OpenAPI files in `swagger/public_v1` and the API release notes are updated.

### Recruitment cycle

- No hard-coded cycle years or dates. Use `Find::CycleTimetable` and the `RecruitmentCycle` records.
- Changes to what providers enter or candidates see are gated on the cycle year rather than a new feature flag, where that fits.
- Code that copies records, such as rollover or course copying, is safe to run more than once.

### Queries and performance

- No N+1 queries on list pages. Associations are preloaded, and `.size` is used on preloaded collections.
- Search queries end their sort order with a unique column, so pages don't repeat or skip results.
- Raw SQL filters out discarded records.

### Tests

- The tests would fail without the change. Check that seed data or stubbed params aren't making them pass.
- System specs find elements by visible text, labels and roles. No new `data-qa` attributes or CSS classes that exist only for tests.
- Time-dependent specs use `travel:` metadata rather than hard-coded years. See [guides/cycle-period-testing.md](/guides/cycle-period-testing.md).
- Each behaviour is tested once at the right level, rather than repeated in system specs.

### Views, components and front end

- User-facing text is in locale files. Keys that receive HTML end in `_html`.
- No logic or local variables in templates; prepare data in the controller, a helper or a component.
- GOV.UK components and form builder helpers are used instead of hand-written GOV.UK markup.
- Styles use GOV.UK spacing and colour functions. JavaScript is in Stimulus controllers.
- Accessibility: headings are in order, links have unique text (add visually hidden context if needed), and content that appears dynamically is announced.

### Jobs

- Retry behaviour is chosen deliberately. Jobs with side effects, such as sending emails, don't retry blindly.
- Job arguments don't carry personal data.

## Reporting

Group findings by severity and leave out empty groups:

```markdown
### Blocking (must fix before merge)
- `path/to/file.rb:123` What is wrong, why it matters, and what to change.

### Recommended (should fix)
- ...

### Optional (nice to have)
- ...

### Docs drift
- `guides/example.md` The guide says X, but this change and recent code do Y. Suggested wording: ...
```

Keep each finding short and plain, so it could be posted as a review comment. Docs drift is never blocking: propose the wording, and fix the docs in a separate change.
