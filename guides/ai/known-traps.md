# Known traps

Parts of the service that have caught developers out, taken from pull request reviews and incidents. Each item says what to watch for and where to read more.

## The recruitment cycle drives behaviour

The current cycle year is worked out from the clock using the dates in `Find::CycleTimetable::CYCLE_DATES`. If the current time falls outside every listed cycle, the app raises an error, so next year's dates must be added well ahead. A `RecruitmentCycle` record must also exist for each year.

The cycle year is not the calendar year, and the year changes when Find closes. Use `Find::CycleTimetable` rather than `Date.current.year`, and use `find_opens` and `apply_opens` for dates shown to users. `RecruitmentCycle#application_start_date` is roughly when Find opens, not when Apply opens.

Read: [guides/phases.md](/guides/phases.md), [guides/cycle-period-testing.md](/guides/cycle-period-testing.md).

## Apply depends on the public API

Apply for teacher training syncs courses and locations from our public API.

- Apply treats `findable` as "candidates can apply to this course" and doesn't check for withdrawn courses itself.
- Apply identifies locations by UUID and closes any that disappear from the sync. Location UUIDs change at rollover.
- Apply decides what to sync from `changed_at` on providers and courses. A change that alters a course's API response without touching `changed_at` won't reach Apply.

Check with the Apply team before changing what any of these mean.

## New tables and columns need more than a migration

Each new table or column needs a decision in the analytics config (`analytics.yml`, `analytics_blocklist.yml`, `analytics_hidden_pii.yml`), the Airbyte stream config, `db/scripts/sanitise.sql` if it holds personal data, and `docs/database-diagram.mmd`. Saved Blazer queries use raw SQL, so renaming or dropping a column can break them without any test failing.

## Schools moved to a new model

Schools are stored in `Provider::School` and `Course::School`, which link to `GiasSchool`. `Site` still holds study sites, and the public API serves older cycles from `Site` and `SiteStatus`. The site code `"-"` marks a provider's main site, so one provider can link the same school twice: once as its main site and once as a placement school.

Read: ADRs 0016–0021 in [guides/adr](/guides/adr/index.md), [guides/data-dictionary.md](/guides/data-dictionary.md).

## "Findable" means published

Find shows any published course (`Course.visible_in_find`), including courses that Support has allowed to have no schools. The older `Course.findable` scope, based on `SiteStatus`, is still used for some reporting. Remember `.kept` when querying courses.

## Rollover must be safe to repeat

Rolling over a single course runs the whole provider copy, so copiers must check for existing records. Rollover jobs don't retry automatically; each provider's result is recorded in `DataHub::RolloverProcessSummary`.

Read: [guides/rollover.md](/guides/rollover.md).

## Discarded records and raw SQL

`discard` adds no default scope, and hand-written SQL ignores it entirely. Filter `discarded_at` yourself. Discarding a site in the past left it attached to live courses.

## Search results need a stable order

Every sort in `Courses::Query` ends with `course.id`. Without a unique final sort key, courses repeated across pages and others never appeared. Distance is calculated in more than one place, so change them together.

Read: ADRs 0020 and 0021 in [guides/adr](/guides/adr/index.md).

## Stored searches outlive code changes

Recent searches and email alerts store search parameters. Renaming a parameter or its values needs a data migration for the stored records.

## Email alerts must not send twice

Weekly alerts lock each alert while sending, and only retry failures where GOV.UK Notify definitely didn't accept the email. Keep that behaviour if you change the job.
