# 18. Roll out school relationship changes with dual writes and feature flags

Date: 12 June 2026

## Status

Accepted

## Context

[ADR 16](0016-model-school-relationships-with-gias-backed-join-tables.md) introduces GIAS-backed provider-school and course-school relationships. [ADR 17](0017-migrate-school-data-into-new-relationship-model.md) covers migrating existing data into that model.

The application cannot switch every school-related read and write path at once. Providers can add and remove schools during the transition, and downstream systems such as Apply rely on API data remaining stable.

We need a rollout approach that keeps old behaviour working while the new model is introduced, avoids missing data in either model, and makes old-model code easy to remove later.

The key write paths are:

- adding a school to a provider;
- bulk URN import for provider schools;
- adding a school to a course through the existing flow;
- adding a school to a course through the new flagged flow;
- removing a provider school; and
- touching parent providers when school relationships change.

## Options

### 1. Switch directly from the old model to the new model

Update write paths and read paths to use the new school relationship model in one release.

#### Pros

- No extended period of dual writes.
- Less temporary branching.
- Old-model cleanup can happen immediately.

#### Cons

- High risk for provider-facing flows and downstream API consumers.
- Harder to verify that backfilled data is equivalent before switching reads.
- Any missed write path could leave new-model data incomplete.
- Rollback would be difficult once old writes stop.

### 2. Backfill once, then freeze old school writes

Run the migration, prevent old school writes, and move users to the new flows.

#### Pros

- Avoids ongoing dual-write complexity.
- Reduces drift after migration.

#### Cons

- Not practical while provider-facing flows still depend on old pages.
- Prevents normal provider updates during rollout.
- Requires a hard operational cutover.
- Still leaves API, search and publishing read paths needing staged migration.

### 3. Dual-write during transition and use feature flags for new read and UI paths

Keep existing flows working, but make them write to both the old and new models. Introduce new flows and read paths behind feature flags. Keep old and new logic clearly separated so the old path can be removed later.

#### Pros

- Keeps current provider-facing behaviour stable during rollout.
- Avoids missing new-model data before the feature flag is enabled.
- Allows API, search, publishing and UI reads to switch in controlled steps.
- Gives a clearer rollback path while old model writes still exist.
- Makes it possible to compare old and new behaviour before cleanup.

#### Cons

- More temporary code.
- Failure handling must avoid silently writing to only one model.
- Tests need to cover old and new paths.
- Cleanup work is required after the new model is fully live.

## Decision

Use dual writes during the transition, with feature flags controlling new read paths and new UI flows.

When a school is added to a provider, both the normal provider-school add flow and bulk URN import should write to:

- the old `Site`-based model; and
- the new provider-school model.

The old and new provider-school write paths should be implemented separately, for example through separate service objects, so each path is easy to reason about and the old path can be removed cleanly later.

When a school is added to a course, the existing old flow should continue writing the old data structure and should also create the new course-school relationship. This prevents gaps in the new model before the feature flag is enabled.

The new add-school-to-course flow should sit behind a feature flag. In the new flow:

- selectable schools come from the provider-school relationship model, not from `Site`;
- providers can only choose schools linked to their organisation in the new provider-school model;
- creating a course school creates the new course-school relationship;
- `gias_school_id` is populated from the provider-school relationship;
- `site_code` is copied from the provider-school relationship; and
- `course_school.provider_school_id` is set.

Failures should be handled so that we do not silently create records in only one model without knowing.

Removing a provider-school relationship should be allowed only when no course-school records reference it through `course_school.provider_school_id`. If one or more course-school records reference the provider-school, removal should be blocked and the provider should be told to remove the school from the course first.

We should not automatically delete course-school records when deleting a provider-school relationship. Blocking removal is safer because it prevents orphaned or surprising course-level changes.

When removal is blocked, the UI should show this error:

> We are unable to remove this school because it is currently attached to a course. Remove the school from the course first.

School relationship changes must touch the relevant parent provider so Apply can detect changed provider data through the API.

This includes:

- creating, updating and destroying provider-school records touching the associated provider;
- destroying course-school records touching the provider associated with the course; and
- confirming or adding equivalent touch behaviour for course-school create/update paths.

The implementation should touch only the relevant provider records and avoid unnecessary broad updates.

## Consequences

The rollout is safer because existing provider-facing behaviour remains available while new-model data is built and verified.

There will be temporary old/new branching. That branching should be explicit and isolated so the old path can be removed once the school remodel feature is fully live.

Dual-write failures become important. Implementations must avoid partial writes being treated as success where that would leave the old and new models inconsistent.

The new course-school flow is constrained by provider-school relationships. This improves data integrity because course schools must come from schools already linked to the provider.

Blocking provider-school removal when course-school records depend on it prevents accidental course-level data loss. It also makes the `provider_school_id` relationship meaningful beyond API UUID lookup.

Touching providers on school relationship changes preserves Apply's sync behaviour. Without this, school changes in the new model could be missed because Apply detects changed providers through provider `updated_at`.

API, publishing, search, rollover, support UI and reporting read-path decisions are covered by [ADR 19](0019-use-new-school-relationships-in-api-search-publishing-and-operations.md).

## Related decisions

- [ADR 16. Model school relationships with GIAS-backed join tables](0016-model-school-relationships-with-gias-backed-join-tables.md)
- [ADR 17. Migrate school data into the new relationship model](0017-migrate-school-data-into-new-relationship-model.md)
- [ADR 19. Use new school relationships in API, search, publishing and operations](0019-use-new-school-relationships-in-api-search-publishing-and-operations.md)
