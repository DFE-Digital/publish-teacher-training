# 16. Model school relationships with GIAS-backed join tables

Date: 12 June 2026

## Status

Accepted

## Context

Publish has historically represented school-related course and provider locations through `Site` records. This includes the legacy main-site concept, where `site_code = "-"` carries special meaning for some downstream behaviour.

This model has become difficult to reason about:

- school-like data is duplicated in `Site` even though GIAS is the authoritative source for schools;
- behaviour differs between Publish, Find, Apply and API consumers;
- main-site behaviour is implicit and coupled to `Site`;
- provider school creation can take a long time when providers bulk add schools, so the current model has pushed that work into asynchronous processing;
- the whole `Site` table is copied during rollover for each year's courses;
- location-based search queries the `Site` table, which is heavily duplicated and bloated because sites are copied every recruitment cycle;
- `Site` records are not updated when their source `GiasSchool` data changes;
- location-based search and API responses depend on legacy school lookup rules;
- the data model is complicated because `Site` carries school relationships, study placements and main-site behaviour; and
- salaried courses need deterministic school/location behaviour even when courses do not have course-specific schools attached.

One of the earlier hurdles was that many main sites could not be matched to a GIAS school. That would have left some school-like records in `Site` and weakened the target model. We have now resolved that blocker and can link the main sites to GIAS schools, so all schools can move into the new join tables. The migration detail is covered in [ADR 17](0017-migrate-school-data-into-new-relationship-model.md).

We need a school relationship model that separates authoritative school data from study placements, preserves required legacy site-code behaviour, and gives later API, search, publishing and rollover work a clear data model to target.

## Options

### 1. Keep using `Site` as the school relationship model

Continue storing school relationships and main-site semantics in `Site`, while adding incremental fixes around API, search and publishing.

#### Pros

- Minimal immediate schema change.
- Existing code paths and API behaviour are already based on this model.
- No migration is needed before changing dependent behaviour.

#### Cons

- Keeps school data coupled to a table that also represents study placements.
- Continues duplication between `Site` and GIAS-backed school data.
- Continues copying school-like `Site` records every rollover.
- Leaves location-based search querying a duplicated and increasingly bloated table.
- Leaves `Site` school data stale when the source GIAS record changes.
- Keeps bulk provider-school additions dependent on long-running asynchronous writes to the old model.
- Leaves main-site behaviour implicit and harder to validate.
- Makes search, API, publishing and rollover changes harder to align.
- Does not provide a clean provider-school relationship for course-school records to reference.

### 2. Keep `Site` for main sites and add GIAS-backed relationships alongside it

Introduce provider-school and course-school relationships, but continue treating main sites as `Site` records.

#### Pros

- Reduces some dependency on `Site` for ordinary school relationships.
- Keeps the legacy main-site representation intact during migration.
- Can be introduced gradually.

#### Cons

- Leaves two school representations in active use.
- Requires code to decide whether school behaviour comes from `Site` or the new relationships.
- Preserves the ambiguity this work is intended to remove.
- Makes main-site compatibility a special case rather than part of the relationship model.
- Keeps some school data outside the GIAS-backed relationship model even though main sites can now be linked to GIAS schools.

### 3. Use GIAS-backed join tables for school relationships and keep `Site` for study placements

Represent provider-school and course-school relationships with explicit join tables backed by `GiasSchool`. Keep `Site` for study placements only.

Both join tables include `gias_school_id` and `site_code`. Provider-school records reference a provider. Course-school records reference a course and the provider-school record they came from.

#### Pros

- Makes `GiasSchool` the authoritative school source for provider and course school relationships.
- Separates school relationships from study placements.
- Avoids copying school-like `Site` records for every recruitment cycle once the old path is retired.
- Allows location-based search to query school relationships backed by GIAS data rather than duplicated `Site` rows.
- Allows school metadata updates from GIAS to flow through the school relationship model instead of leaving copied `Site` data stale.
- Preserves legacy `site_code` behaviour without keeping schools in `Site`.
- Allows main-site behaviour to be validated directly using `site_code = "-"`.
- Gives course-school records a clear relationship back to provider-school records.
- Gives API and Apply compatibility a single UUID source through `provider_school.uuid`.
- Makes later cleanup of old `Site` school behaviour possible.

#### Cons

- Requires data migration and dual-write behaviour during rollout.
- Requires feature-flagged read paths while old and new models coexist.
- Existing code that expects school data in `Site` must be audited and moved.
- Some legacy concepts, especially main-site behaviour, still need to be preserved through `site_code`.

## Decision

Use explicit GIAS-backed join tables for school relationships.

The provider-school relationship records:

- belong to a provider;
- belong to a `GiasSchool`;
- store `site_code`;
- store `uuid`; and
- are the replacement for legacy provider/location records previously represented through `Site`.

The course-school relationship records:

- belong to a course;
- belong to a `GiasSchool`;
- store `site_code`;
- belong to the relevant provider-school record through `provider_school_id`; and
- do not store their own UUID.

The UUID belongs on `provider_school` because it represents the provider/school relationship that replaces the legacy location concept. We will not add a UUID to `course_school` or `gias_school`. When a course-school UUID is needed, code should join through `course_school.provider_school` and use `provider_school.uuid`.

`course_school.provider_school_id` is part of the model, not just an API convenience. It records which provider-school relationship a course-school relationship came from, avoids duplicating UUIDs, and supports deletion rules for provider schools that are used by courses.

Main-site behaviour is represented by `site_code = "-"`, not by a separate `main_site` boolean. A provider may have at most one provider-school relationship with `site_code = "-"`. This rule should be enforced with database constraints where practical and with matching model validations.

Course-school records should copy `site_code` from the matching provider-school relationship. If the provider-school relationship has `site_code = "-"`, the course-school relationship should also use `site_code = "-"`.

Add `region_code` to `gias_school` and populate it from the GIAS import, expected from the GOR column after confirming the current export. Code that needs school region data should use `gias_school.region_code` rather than legacy `Site` data.

`Site` remains in the application for study placements. It should no longer be the long-term source for school relationships.

## Consequences

The school model becomes easier to reason about: schools are represented by GIAS-backed relationships, while study placements remain in `Site`.

Provider-school additions no longer need to be shaped around creating large numbers of school-like `Site` records as the long-term model. Bulk creation can target relationship rows backed by existing GIAS schools.

Rollover no longer needs to copy school-like `Site` records once the new path is live. It can copy provider-school and course-school relationships into the new recruitment cycle instead.

Location-based search can move away from a duplicated `Site` table and query GIAS-backed school relationships instead.

School metadata can be kept aligned with GIAS imports because school attributes live on `GiasSchool`, not on copied `Site` records that drift from their source.

Legacy site-code behaviour is preserved, including main-site semantics, but it is carried on the relationship rows rather than requiring school lookup through `Site`.

The provider-school relationship becomes the single source for school/location UUIDs used by downstream systems such as Apply. This avoids denormalising UUIDs into `course_school` and keeps `gias_school` free of relationship-specific identifiers.

Course-school records are more tightly connected to provider-school records. This gives us a clear rule for removal: a provider-school cannot be removed while course-school records still reference it.

The model introduces more migration and rollout work because old and new models need to coexist temporarily. That rollout is covered by [ADR 17](0017-migrate-school-data-into-new-relationship-model.md) and [ADR 18](0018-roll-out-school-relationship-model-with-dual-writes-and-feature-flags.md).

Application areas that read school relationships need to move to the new model in controlled steps. API, publishing, search, rollover and support implications are covered by [ADR 19](0019-use-new-school-relationships-in-api-search-publishing-and-operations.md).

## Related decisions

- [ADR 17. Migrate school data into the new relationship model](0017-migrate-school-data-into-new-relationship-model.md)
- [ADR 18. Roll out school relationship changes with dual writes and feature flags](0018-roll-out-school-relationship-model-with-dual-writes-and-feature-flags.md)
- [ADR 19. Use new school relationships in API, search, publishing and operations](0019-use-new-school-relationships-in-api-search-publishing-and-operations.md)
