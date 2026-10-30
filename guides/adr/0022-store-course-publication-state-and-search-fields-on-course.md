# 22. Store course publication state and search fields on Course

Date: 20 October 2026

## Status

Proposed

## Context

`CourseEnrichment` was designed to support several versions of a course's
content. A published enrichment could remain live while a provider edited a
separate draft, then the draft could replace it at publication. The current
publishing workflow no longer creates that second draft. Providers edit a
published enrichment in place, and the data migration
`DeleteSubsequentDraftEnrichments` removed the old unpublished-change rows.
The target model therefore has one effective current representation of a
course, with no runtime version selection and no use of `CourseEnrichment`.
This ADR decides which lifecycle and search fields move directly to `Course`;
a later decision can choose the final non-versioned storage for the remaining
long-form content.

Publication is nevertheless still modelled as a property of an enrichment.
`Course#content_status` calls `Courses::ContentStatusService`, and Find decides
whether a course is visible through subqueries over `course_enrichment`. The
Publish course list independently reproduces that service as a SQL `CASE`
expression. This gives one course two representations of the same lifecycle:
the course is the object providers publish and candidates visit, but another
table is the source of truth for whether it is published.

It also makes the candidate search result path depend on enrichments for a
small set of scalar values:

- base Find visibility checks enrichment status;
- the interview-location filter reads `InterviewLocation` from enrichment
  JSON;
- newest-course ordering and weekly email alerts read
  `last_published_timestamp_utc`;
- UK and international fee ordering reads and casts JSON values; and
- result cards preload the latest published enrichment to show those fees.

Saved courses repeat some of the same status, ordering and fee lookups. By
contrast, a course page and the public API already need the enrichment's
long-form content, so moving one of those fields would not remove their
enrichment query.

Historical courses may still have several enrichments, so migration code
cannot assume one row while reading the old model. Those versions are
migration input, not part of the target domain model. The migration will
select the effective current state and content, copy each field to its new
authoritative storage, and eventually remove the old rows and table rather
than preserving version selection in application code.

Publication is also separate from other course state:

- `application_status` says whether a published course accepts applications;
- a future-cycle published course is displayed as scheduled;
- `discarded_at` records deletion; and
- legacy site vacancy and status columns do not decide current Find
  visibility.

We need to make publication state explicit without folding those independent
concepts into one ambiguous course status. We also need an incremental route
to the final model so that publication and the Find result path can be moved
first without coupling the initial change to every narrative field and API
consumer.

## Options

### 1. Keep publication and all content on CourseEnrichment

Continue deriving course state and search values from the latest relevant
enrichment.

#### Pros

- No data migration or cutover.
- Historical multi-enrichment behaviour remains untouched.
- Content continues to have one storage location.

#### Cons

- The course's lifecycle remains owned by a related content record.
- Ruby and SQL implementations of the derived state can diverge.
- Find and Saved courses retain lateral joins, subqueries, JSON extraction and
  an enrichment preload for scalar fields.
- A later replacement of `course_enrichment` has no clear first boundary.

### 2. Move only publication status to Course

Add a text-backed enum to `course` and leave timestamps, fees and interview
location on the enrichment.

#### Pros

- Smallest change that makes publication an explicit property of a course.
- Simplifies Find visibility and the Publish course-list status query.
- Makes the lifecycle vocabulary and permitted values visible in the schema.

#### Cons

- Find still joins enrichments for newest ordering, alerts, fee ordering,
  interview filtering and result-card fees.
- Two storage models remain on the same high-traffic query path.
- A second migration is already foreseeable for a tightly related set of
  scalar values.

### 3. Retire CourseEnrichment in stages

Make `course` authoritative for publication state and its timestamps, and
move the small scalar values that Find filters, sorts or renders in its result
set first. Move the remaining enrichment content to its final non-versioned
storage in later phases, then remove `course_enrichment`.

#### Pros

- Find results and weekly-alert discovery can stop reading
  `course_enrichment`.
- Publication, application state and deletion remain explicit, independent
  course properties.
- Typed columns replace repeated JSON extraction and integer casts for fees.
- The highest-value query coupling is removed first without making the first
  release carry the entire content migration.
- The target model has one owner for the course lifecycle and for each content
  field.

#### Cons

- More fields and writers must be migrated than in option 2.
- Migrated values temporarily exist in both models and need reconciliation
  until the enrichment copy is removed.
- Course editing code and validations for the moved fields must change.
- The public API and course pages continue using `course_enrichment` during
  the intermediate phases.

### 4. Move all enrichment fields to Course

Treat the enrichment as obsolete and migrate its JSON content, status,
timestamps and audit data in one change.

#### Pros

- Removes the current split between course and enrichment data.
- Removes the enrichment association and table in one change.

#### Cons

- Couples the publication-state change to a much larger content and API
  migration.
- Makes common `course.*` queries carry many long-form text values.
- Requires an immediate decision about historical versions and enrichment
  audit metadata.
- Increases the size, rollback risk and verification burden of the first
  change.

## Decision

Use option 3. `CourseEnrichment` is a transitional model: application code
will eventually stop reading and writing it, and the table will be removed.
This ADR chooses `Course` as the owner of the lifecycle and search-facing
fields below. It does not require every long-form field to become a column on
`course`; their final non-versioned storage will be decided as part of the
later replacement work.

The initial extraction from `course_enrichment` will add these typed columns
to `course`:

| Column | Type | Reason |
| --- | --- | --- |
| `publication_status` | text-backed enum | Replaces the derived lifecycle state used by Publish and Find. |
| `last_published_at` | timestamp | Supports newest ordering, weekly alerts and “last updated” without an enrichment join. |
| `fee_uk_eu` | integer | Displayed on result cards and used for Find and Saved-course ordering. Its validation already depends on course funding and visa fields. |
| `fee_international` | integer | Displayed and ordered with the UK fee, and validated against course visa sponsorship. |
| `interview_location` | text | Used directly by a Find filter. |

`first_published_at` already lives on `course` and will remain there.

These columns are the first migration boundary, not a permanent split between
the models. Later phases will move `course_length` and every remaining current
content field out of the enrichment JSON, switch editing, course-page, export
and public API consumers, and remove the enrichment association and table.
Historical enrichment versions will not be re-created in the replacement
model; only the effective current values are migrated.

The Rails enum for `publication_status` will store strings, not integer enum
ordinals:

```ruby
enum :publication_status, {
  draft: "draft",
  rolled_over: "rolled_over",
  published: "published",
  withdrawn: "withdrawn",
}, prefix: :publication
```

The name is `publication_status`, rather than `content_status` or
`published_status`. It describes the publication lifecycle of the whole
course. “Published” is one value within that lifecycle, while
`published_status` reads as a property that applies only after publication.
The prefix also gives unambiguous predicates such as
`publication_published?` and avoids collisions with other status concepts.

The database will ultimately enforce a non-null value constrained to those
four strings. New courses will default to `draft`; rollover must explicitly
set `rolled_over`. The application must update state through the existing
publication, withdrawal, withdrawal-reversal, rollover and copy workflows,
rather than through a general-purpose callback.

The following display states are derived and will not become enum values:

- `scheduled` is `published` in a future recruitment cycle;
- `open` and `closed` combine `published` with `application_status`;
- discarded is represented by `discarded_at`; and

### Migration and cutover

Temporarily write each migrated value to both `course` and
`course_enrichment`. This is a compatibility mechanism, not two equal sources
of truth: enrichment readers remain authoritative before the reader switch;
`Course` is authoritative afterwards, while the enrichment copy is maintained
only for consumers that have not moved yet.

For the first migration phase:

1. Add nullable `course` columns without changing readers.
2. Update every mutation path for the moved fields to write both models in the
   same database transaction. This includes course editing, publishing,
   withdrawal, withdrawal reversal, rollover, copying and support operations.
   Keep this synchronisation in the explicit workflows that own those changes
   rather than introducing an open-ended model callback.
3. Backfill and verify the new columns while dual writes keep subsequent
   changes synchronised:
   - map `publication_status` with the current
     `Courses::ContentStatusService` semantics, including no enrichment,
     historical multiple enrichments and the old subsequent-draft case;
   - set `last_published_at` to the greatest
     `last_published_timestamp_utc` for the course; and
   - take scalar content from `Course#latest_published_enrichment` for a
     published course, and from the latest enrichment for other publication
     states. This preserves the content currently exposed by Find for the
     legacy subsequent-draft case.
4. Reconcile the two representations and resolve mismatches before switching
   readers. The comparison must cover all courses, not only the current cycle.
5. Switch Publish status, Find, Saved courses, exports, weekly alerts and the
   public API attributes for the migrated fields to `course`. Add the default,
   non-null requirement, check constraint and appropriate indexes. The Find
   results relation and card must no longer need an enrichment for
   publication, interview location, newest ordering or fees.
6. Continue writing the migrated fields to both models while the enrichment
   replacement is completed. This keeps the transitional model internally
   consistent and avoids a separate cutover for each consumer.
7. Repeat the process for `course_length` and the remaining narrative content,
   using the non-versioned storage selected by the replacement work.
8. Remove all remaining runtime enrichment reads and all compatibility writes
   together, then drop the association, compatibility code and
   `course_enrichment` table.

This approach permits normal editing and publishing throughout the migration
and allows readers to move independently. If historical version data has a
retention requirement, it must be archived outside the live course model
before the table is dropped; it will not remain part of course selection or
publishing behaviour.

## Consequences

There will be one persisted publication state for a course. Ruby predicates,
Publish list filtering and Find visibility will no longer need separate
implementations of enrichment-derived status.

Find can query `course` directly for visibility, interview location, newest
ordering and fees. Result cards can render fees without preloading an
enrichment, and weekly alerts can start from courses changed since a timestamp
instead of starting from published enrichment rows. Saved-course withdrawal
and fee handling can use the same columns.

Application status remains orthogonal. Closing applications does not
unpublish a course, and publishing opens applications through the existing
workflow without merging those two fields. Vacancy and legacy site state also
remain outside publication.

The migration temporarily duplicates data, but it does not require a write
pause or an atomic switch across every running application process. The cost
is the possibility of drift between copies. Dual writes must be transactional,
all mutation paths must be covered, and reconciliation must continue until the
compatibility copy is no longer read. After the reader switch, `Course` wins if
a discrepancy is found.

Historical rows require deliberate backfill rules; selecting an arbitrary
enrichment would change old Saved-course and API behaviour. The migration's
selection logic must be tested with no enrichment, one enrichment, historical
multiple enrichments and the legacy subsequent-draft shape.

During the intermediate phases, the public API and course detail page will
read migrated scalar fields from `Course` and continue loading
`CourseEnrichment` only for content that has not moved yet. In the final state,
none of those consumers reads `CourseEnrichment`, which no longer exists as an
application model or database table.

## Related decisions

- [ADR 14. Recent Searches and Email Alerts for Find Teacher Training](0014-recent-searches-email-alert.md)
- [ADR 20. Find non-location course search](0020-find-non-location-course-search.md)
- [ADR 21. Find location course search](0021-find-location-course-search.md)
