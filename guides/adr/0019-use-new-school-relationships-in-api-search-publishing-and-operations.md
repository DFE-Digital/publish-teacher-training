# 19. Use new school relationships in API, search, publishing and operations

Date: 12 June 2026

## Status

Accepted

## Context

[ADR 16](0016-model-school-relationships-with-gias-backed-join-tables.md) introduces the new school relationship model. [ADR 18](0018-roll-out-school-relationship-model-with-dual-writes-and-feature-flags.md) decides to roll it out with dual writes and feature flags.

Several application areas read school/location data and need to move from the old `Site`-based model to the new provider-school and course-school relationships:

- course publishing checks;
- public API school/location responses;
- Apply-facing location UUID behaviour;
- location-based course search;
- recruitment cycle rollover;
- support/admin school pages; and
- Blazer reporting queries.

The goal is to switch backing data models without changing product behaviour unless a specific ticket says to do so. In particular, the school remodel publishing work does not introduce support for publishing courses without schools.

## Options

### 1. Update every consuming area to the new model in one release

Switch publishing, API, search, rollover, support UI and reporting queries to the new school relationships together.

#### Pros

- Shorter transition period.
- Less temporary branching across consuming code.
- Faster removal of old `Site` school logic.

#### Cons

- High regression risk across candidate, provider, support and downstream API behaviour.
- Harder to isolate failures to one consuming area.
- API consumers and Apply would have less time to validate compatibility.
- Search and publishing behaviour could change unexpectedly at the same time.

### 2. Keep consuming areas on `Site` until the old model is removed

Create and backfill the new relationships, but continue using `Site` for API, search, publishing, rollover and support until a later cleanup.

#### Pros

- Minimal immediate risk to existing behaviour.
- Allows time to inspect migrated data.

#### Cons

- Delays the value of the remodel.
- Keeps business logic coupled to the model we are trying to retire.
- Increases the period where old and new data can drift.
- Does not test the new model through real read paths.
- Makes rollover especially awkward because new-cycle data would continue copying school `Site` records.

### 3. Move consuming areas behind feature flags or isolated branches

Switch each consuming area to the new school relationship model in controlled steps. Keep old logic available while the feature flag is off, and isolate old/new branches so old code can be removed later.

#### Pros

- Keeps existing behaviour unchanged while flags are off.
- Allows API, search, publishing and rollover changes to be verified independently.
- Supports incremental rollout and rollback.
- Makes old-model cleanup easier because branch points are explicit.
- Allows additive API changes needed for Apply without broad API shape changes.

#### Cons

- Requires temporary branching in several areas.
- Test coverage must cover both feature flag states.
- Requires deliberate cleanup once the feature is fully live.

## Decision

Move consuming areas to the new school relationship model through feature flags or explicit isolated branches, preserving current product behaviour unless the relevant ticket says otherwise.

### Publishing

Course publishing rules that depend on schools should switch by feature flag.

When the flag is off, publishing checks continue to use the old `Site`-based model. When the flag is on, equivalent checks use provider-school and course-school relationships.

Provider-facing publishing behaviour should remain functionally the same. Courses that currently require schools to publish should still require schools to publish. This work does not introduce support for publishing courses without schools.

Old-model publishing logic should be identified and isolated so it can be removed cleanly later.

### API locations and UUIDs

API school/location responses should continue using the old model while the school remodel feature flag is off.

When the feature flag is on, API school/location responses should use:

- course-school records when a course has course schools; and
- provider-school records as fallback when a course has no course schools.

The provider-school fallback is needed during the transition because Apply syncs courses with attached schools. It also supports courses where provider-level school relationships exist but course-specific schools have not been attached.

The location API response should include an additive key indicating whether the returned locations are course-specific schools or provider-level fallback schools. The ticket suggests `has_course_schools`.

The value should be:

- `true` when locations come from course-school records; and
- `false` when locations fall back to provider-school records.

Location UUIDs should come from `provider_school.uuid`. For course schools, the API should return the UUID by joining through `course_school.provider_school`.

We should not add UUIDs to `course_school` or `gias_school` for API convenience.

All API endpoints that expose school/location data should be reviewed and updated where needed.

### Location-based search

Location-based course search should gain a new query path using the provider-school and course-school relationship model.

The existing query service should remain in place while the feature flag is off. When the feature flag is on, location-based search should use the new query service and the new school data model.

The product behaviour should remain equivalent from the user's point of view. The work is to change the backing model, not to change which courses should appear in expected search scenarios.

Old and new query paths should be clearly separated so query selection is easy to trace and old code can be removed later.

### Rollover

Rollover should support the new school relationship model.

Today, rollover copies school `Site` records into the new recruitment cycle and associates them to copied courses. In the new path, rollover should not create copied school `Site` records for the new cycle.

Instead, rollover should copy school relationship data:

- provider-school relationships should be copied to the equivalent new-cycle provider records;
- course-school relationships should be copied to the equivalent new-cycle course records;
- copied records should point at the correct copied provider and course records;
- `gias_school_id` should be carried across; and
- `site_code` should be carried across.

The old `Site` school-copying path should be isolated behind clear logic or branching so it can be removed later.

### Support UI and reporting

School-related support/admin pages should be reviewed and updated so they read and write the correct model during rollout.

This includes pages that display, add, remove or edit schools. Editing behaviour needs particular attention so support actions do not accidentally update only the old model where the new model should also be updated.

Any old/new branching in support UI should be explicit and isolated. If a page still needs old-model support temporarily, that should be clear in the code.

Important Blazer queries that read school data, join through `sites`, or rely on provider-school/course-school relationships should be reviewed. Broken or incomplete queries should be fixed where appropriate, and any queries that should not be changed yet should be recorded for follow-up.

## Consequences

Publishing, API, search and rollover can move to the new model without a single high-risk cutover.

Feature-flagged and isolated branches mean tests must cover both old and new paths. This is temporary but necessary while old and new models coexist.

The public API shape changes only where needed. The `has_course_schools` key is additive, and UUID values remain compatible with Apply by coming from `provider_school.uuid`.

The provider-school fallback in the API makes courses with no course-school records visible to Apply during transition, but it also means API consumers need a clear signal showing whether returned locations are course-specific or provider-level fallback locations.

Search and publishing should keep equivalent product behaviour while using the new backing model. Any behaviour change should be handled separately from the model switch.

Rollover becomes aligned with the new model by copying relationship rows instead of creating school `Site` records for the new cycle.

Support UI and Blazer queries are operational dependencies of the remodel. They do not need separate ADRs unless they introduce new architectural decisions, but they must be reviewed because stale old-model logic could otherwise produce incorrect support actions or reporting.

## Related decisions

- [ADR 16. Model school relationships with GIAS-backed join tables](0016-model-school-relationships-with-gias-backed-join-tables.md)
- [ADR 17. Migrate school data into the new relationship model](0017-migrate-school-data-into-new-relationship-model.md)
- [ADR 18. Roll out school relationship changes with dual writes and feature flags](0018-roll-out-school-relationship-model-with-dual-writes-and-feature-flags.md)
