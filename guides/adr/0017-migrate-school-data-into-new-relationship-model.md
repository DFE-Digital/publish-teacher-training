# 17. Migrate school data into the new relationship model

Date: 12 June 2026

## Status

Accepted

## Context

[ADR 16](0016-model-school-relationships-with-gias-backed-join-tables.md) decides that school relationships should move from legacy `Site`-based storage to GIAS-backed provider-school and course-school relationships.

Existing production data still lives in the old model. The migration needs to preserve legacy behaviour where it is still externally visible, especially:

- `site_code`, including `site_code = "-"` for main sites;
- existing UUIDs used by Apply to identify locations;
- provider-school and course-school relationships; and
- enough information to keep old and new read paths equivalent during rollout.

The current-cycle analysis showed a manageable number of main sites without URNs:

- 110 current-cycle main sites had no URN;
- 99 could be matched automatically using postcode; and
- 11 were expected to need manual resolution.

Later tickets refined the migration approach. Main sites are not being removed as part of this remodel. Instead, main-site relationships should also be migrated into the new through tables where they can be linked to `GiasSchool`.

The earlier inability to match many main sites to GIAS schools was a blocker for moving all schools into the join tables. That blocker has now been resolved: main sites can be linked to GIAS schools, so the migration can move all school relationships into the new provider-school and course-school tables.

An edge case exists where a provider or course can have:

- a normal school relationship for a GIAS school; and
- a main-site relationship for the same GIAS school.

The migration must not collapse those into one row when one row represents a main site.

## Options

### 1. Perform a broad automatic migration and infer missing school links aggressively

Try to populate as much data as possible automatically, including ambiguous missing-URN cases.

#### Pros

- Reduces manual follow-up.
- May produce a more complete initial migration.
- Keeps the migration process short.

#### Cons

- Risks linking a provider or course to the wrong school.
- Incorrect school relationships would be externally visible through API, Apply and search.
- Ambiguous postcode matches are not reliable enough to update automatically.
- Harder to audit and correct after the fact.

### 2. Migrate only records that already have URNs

Skip all records without URNs and leave unresolved main sites to be handled separately.

#### Pros

- Very conservative.
- Avoids accidental wrong matches.
- Easier migration logic.

#### Cons

- Leaves avoidable manual cleanup for records that can be confidently matched or have now been resolved.
- Delays the move away from `Site`.
- Increases the chance that old and new models behave differently during rollout.

### 3. Use a conservative, repeatable backfill with explicit handling for main-site rows

Backfill new relationship rows from existing data by resolving URNs to `gias_school_id`, preserving `site_code`, preserving legacy UUIDs on `provider_school`, and allowing the main-site duplicate case only when one row has `site_code = "-"`.

#### Pros

- Preserves externally visible identifiers and site-code behaviour.
- Avoids risky automatic updates for ambiguous missing-URN records.
- Allows confident postcode matches to reduce manual work.
- Supports production data volumes with a bulk approach where practical.
- Can be rerun safely during rollout.
- Handles the discovered main-site duplicate edge case.

#### Cons

- More migration logic than a one-off direct copy.
- Requires logging and follow-up for skipped or ambiguous records.
- Requires careful uniqueness constraints so valid main-site duplicates are allowed without allowing broad duplication.
- Requires migration and dual-write code to understand `provider_school_id`.

## Decision

Use a conservative, repeatable backfill into the new provider-school and course-school relationship tables.

Before the main backfill, current-cycle main sites with missing URNs should be updated only where a confident match can be made. Matching by postcode is acceptable only when it produces a single confident school match. The migration must not overwrite existing URNs and must not touch other recruitment cycles for this preparatory step.

Unmatched or ambiguous records should be logged or output for manual follow-up. We should record how many current-cycle records were updated automatically and how many remain unresolved.

Because the remaining main-site matching has now been resolved, main-site records should be included in the migration rather than left behind in `Site`.

The main backfill should:

- read existing school relationship data from the old model;
- extract URNs from the existing data;
- resolve URNs to `gias_school_id`;
- create provider-school records;
- create course-school records;
- copy `site_code` into both relationship tables;
- copy existing legacy `Site` UUIDs into `provider_school.uuid`;
- link course-school rows to the correct provider-school row through `provider_school_id`;
- skip rows without a usable URN;
- log skipped rows for follow-up; and
- be idempotent or otherwise safely repeatable.

The implementation should be designed for production data volumes. A SQL-first or bulk approach is preferred where practical. If a non-bulk ActiveRecord-heavy approach is chosen, the performance trade-off should be documented.

The backfill may create separate provider-school or course-school records for the same provider/course and `gias_school_id` only where one of those records represents a main site using `site_code = "-"`. Normal duplicate protection still applies for non-main-site rows.

Any database uniqueness assumptions that prevent this valid main-site duplicate should be reviewed and amended narrowly. The duplicate rule should not be relaxed more broadly than needed.

## Consequences

The migration preserves compatibility data needed by Apply and API consumers while moving school relationships into the new model.

The migration remains auditable because uncertain records are skipped and reported instead of being guessed. This leaves some manual work, but it avoids introducing wrong school relationships into production data.

The idempotent design allows the backfill to be rerun during rollout without duplicating valid rows.

Preserving UUIDs on `provider_school` keeps the new model compatible with downstream location lookups. Linking `course_school` to `provider_school` means course-school API responses can return the same relationship UUID without duplicating it.

Allowing the main-site duplicate case prevents data loss where a provider or course has both a normal school relationship and a main-site relationship for the same GIAS school. The cost is more careful uniqueness logic and clearer tests around duplicate protection.

The migration deliberately does not switch application read paths by itself. Dual-write and feature-flag rollout decisions are covered by [ADR 18](0018-roll-out-school-relationship-model-with-dual-writes-and-feature-flags.md).

## Related decisions

- [ADR 16. Model school relationships with GIAS-backed join tables](0016-model-school-relationships-with-gias-backed-join-tables.md)
- [ADR 18. Roll out school relationship changes with dual writes and feature flags](0018-roll-out-school-relationship-model-with-dual-writes-and-feature-flags.md)
- [ADR 19. Use new school relationships in API, search, publishing and operations](0019-use-new-school-relationships-in-api-search-publishing-and-operations.md)
