# 22. Course publication state and CourseEnrichment

Date: 20 October 2026

Last updated: 20 November 2026

## Status

Proposed

## Context

`CourseEnrichment` was designed to support several versions of a course's
content. A published enrichment could remain live while a provider edited a
separate draft, then the draft could replace it at publication. The current
workflow no longer creates that second draft. Providers edit published content
in place, and the `DeleteSubsequentDraftEnrichments` migration removed the old
unpublished-change rows.

The versioned model remains in the schema and application behaviour, even
though parallel versions are no longer part of the intended domain. Historical
courses can still have several enrichments, so existing data and migration code
cannot assume that every course has exactly one row.

This ADR records the problems with the current model, the constraints on a
replacement, and the options to evaluate. It does not yet select an option or
decide where every enrichment field should ultimately live.

## Problems raised by the development team

### CourseEnrichment data model

#### Versioning no longer fits the domain

Multiple enrichment rows and competing statuses remain possible even though
providers no longer work on a draft alongside published content. It can be
unclear which row is authoritative, and "latest" has different meanings in
different parts of the application.

#### Course and enrichment are tightly coupled

Many consumers need both records to understand one course. This introduces
associations, eager loading, subqueries and lateral joins for data that behaves
as part of the current course rather than as an independently versioned entity.

#### Course content is weakly modelled

Most enrichment content is stored in one JSON column. The database cannot
provide normal column types and constraints for those values, keys retain
legacy naming such as `FeeUkEu`, and values such as `course_length` behave like
an enum while remaining free text.

#### Search-critical data is buried in the content JSON

Find filters, sorts and result cards use scalar values such as fees and
interview location. Reading and ordering by those values requires enrichment
selection, JSON extraction and, for fees, casting values before comparison.

#### The API can drift from the model

API attributes are mapped separately from the enrichment JSON. Adding,
renaming or changing a content field can therefore require coordinated updates
that are easy to miss.

#### Audit responsibility is duplicated

The enrichment carries `created_by` and `updated_by` ownership while the
application also has audit history. We need to decide which information is
domain data and which belongs to the audit mechanism before migrating it.

### Publishing flow

#### There is no single source of truth for publication state

`Course#content_status`, `Course#is_published?`, Publish list SQL, Find
visibility and API behaviour do not all ask the same question in the same way.
They can disagree about whether a course is published or visible.

#### Publishing changes several independent concerns

`PublishService` publishes draft or rolled-over enrichments, undiscarding the
course, opening applications, setting first-publication data and recording the
publishing user and timestamp. These side effects make it difficult to state
what the publication transition itself owns.

#### Publication has no explicit transition or event model

The workflow changes several fields, but there is no explicit state machine or
single publish event. Similar actions have confusing names, and their permitted
transitions and side effects are not represented in one place.

#### Validation and feedback are spread across models

Publishability is assembled from validations across the course and related
models. Historical enrichment rows can therefore affect validation even though
they are not intended to represent parallel editable versions. This complicates
the publishing path and makes it harder to give a provider clear, timely
feedback about what prevents publication.

#### Lifecycle actions reuse the content table

Rollover and withdrawal are represented through enrichment statuses even
though they describe the course lifecycle rather than a version of its
content. Withdrawal also suspends site statuses in the legacy model, further
coupling publication, content and availability behaviour.

#### Publication timestamps require manual coordination

The value used as the last-published or last-updated time is maintained as part
of application workflows. Writers can miss it, and readers need to know which
timestamp on which record carries the intended meaning.

## Current behaviour and query dependencies

Publication is currently derived from enrichment data. `Course#content_status`
uses `Courses::ContentStatusService`; Find uses enrichment subqueries to decide
visibility; and the Publish course list reproduces status derivation in a SQL
`CASE` expression. A published enrichment is also used as evidence by Find and
reporting, while the latest enrichment can change the derived status to
withdrawn or rolled over.

The publish transaction currently performs several changes together:

- validates the course for publication;
- changes draft and rolled-over enrichments to published;
- undiscards the course;
- sets `first_published_at` for a first publication;
- sets `application_status` to open; and
- records publication metadata on the enrichment.

The candidate search result path reads a relatively small set of scalar values
from enrichments:

| Use | Current enrichment dependency |
| --- | --- |
| Find visibility | Enrichment status and legacy multi-row rules |
| Interview-location filter | `InterviewLocation` from enrichment JSON |
| Newest ordering and weekly alerts | `last_published_timestamp_utc` |
| UK and international fee ordering | JSON extraction and integer casts |
| Result-card fees | Preloaded latest published enrichment |

Saved courses repeat some of the same status, ordering and fee lookups. A
course detail page and the public API need the long-form content as well, so
moving only the search-facing scalar values would not remove every enrichment
read.

Publication must remain distinguishable from other course state:

- `application_status` says whether a published course accepts applications;
- a future-cycle published course can be presented as scheduled;
- `discarded_at` records deletion; and
- site status and vacancy data do not determine current Find visibility.

## Decision drivers

- Give publication state one authoritative owner and definition.
- Make lifecycle transitions and their side effects explicit.
- Keep publication, application availability, scheduling and deletion as
  separate concepts.
- Remove version-selection behaviour that is no longer part of the domain.
- Reduce joins, JSON extraction and duplicated status logic on Find and Saved
  course paths.
- Give frequently queried scalar data useful database types and constraints.
- Avoid making common course queries unnecessarily load long-form content.
- Keep the public API compatible or version changes deliberately.
- Preserve required audit and historical information without keeping obsolete
  runtime versioning.
- Allow historical data to be migrated deterministically, including courses
  with no enrichment or several enrichments.
- Support a safe transition while providers continue editing and publishing
  courses.

## Fields to evaluate separately

Moving publication state does not require every content field to move at the
same time. These fields have a stronger case for early extraction because they
are used outside the course detail and editing paths:

| Candidate field | Reason to evaluate it |
| --- | --- |
| Publication state | The whole course is published, and several consumers currently reimplement an enrichment-derived state. |
| Last-published timestamp | Find ordering, alerts and last-updated displays should not require selecting an enrichment. |
| UK fee | Find and Saved courses sort by it and result cards display it; a typed column avoids JSON casting. |
| International fee | It is displayed and ordered with the UK fee and has course-level validation dependencies. |
| Interview location | Find filters directly on it, so keeping it in JSON adds work to the result query. |
| Course length | It is currently free text but behaves like structured data; its valid vocabulary and ownership need agreement first. |

The remaining narrative fields do not have the same search-path benefit. Their
destination should be chosen as part of the wider content-model decision,
rather than assuming that all of them belong directly on `course`.

## Options

### 1. Keep publication and all content on CourseEnrichment

Continue deriving course state and search values from the relevant enrichment.

#### Pros

- Requires no data migration or consumer cutover.
- Leaves historical multi-enrichment behaviour untouched.
- Keeps all content in one storage location.

#### Cons

- Retains versioning that no longer fits the workflow.
- Leaves the course lifecycle owned by a related content record.
- Allows Ruby, SQL, Find and API interpretations of state to diverge.
- Keeps search joins, JSON extraction and content preloading for scalar data.

### 2. Move only publication state to Course

Add a text-backed state field to `course`, leaving timestamps and all content
on the enrichment.

#### Pros

- Is the smallest change that makes publication an explicit course property.
- Can simplify Find visibility and the Publish course-list query.
- Makes the permitted publication values visible in the schema.

#### Cons

- Find still reads enrichments for newest ordering, alerts, fees and interview
  location.
- Leaves two storage models on the same high-traffic query path.
- Does not address weakly typed JSON content or obsolete versioning by itself.

### 3. Move publication and search-facing fields first

Make `course` authoritative for publication and selected typed scalar values,
then decide and migrate the remaining content separately.

#### Pros

- Can remove enrichment access from Find results and weekly-alert discovery.
- Replaces repeated JSON extraction and fee casting with typed columns.
- Creates a smaller first boundary than a complete content migration.
- Allows fields to move according to how they are used rather than treating
  the JSON document as indivisible.

#### Cons

- Creates an intentional intermediate split between two models.
- Requires temporary synchronisation or a coordinated cutover for each moved
  field.
- Course editing, validation and API mappings must be updated carefully.
- Does not decide the final home of narrative content.

### 4. Move all enrichment fields to Course

Treat the enrichment as obsolete and migrate its content, status, timestamps
and required audit data to `course`.

#### Pros

- Removes the current one-course/two-model split.
- Can remove the enrichment association and table in one programme of work.
- Gives all current course data one owner.

#### Cons

- Couples publication work to a much larger content and API migration.
- Makes common `course.*` queries carry many long-form values unless they are
  explicitly deferred.
- Requires immediate decisions about every JSON field, historical version and
  audit attribute.
- Increases migration, rollback and verification risk.

### 5. Replace CourseEnrichment with a non-versioned content model

Put publication and other course lifecycle state on `course`, while replacing
the versioned enrichment with a one-to-one content model for narrative or less
frequently queried fields.

#### Pros

- Removes obsolete version selection without making `course` carry all
  long-form content.
- Gives lifecycle state and content distinct ownership.
- Provides an opportunity to replace the untyped JSON with explicit columns or
  a deliberately defined document schema.

#### Cons

- Still requires a join for course detail and API content.
- Introduces and migrates to another model rather than simply removing one.
- Requires agreement on the boundary between `course` and the content model.
- Does not improve search unless search-facing fields move to `course` as well.

## Open questions

- What does the publication state describe: published content, candidate
  visibility, or the lifecycle of the whole course?
- Should the state be a simple text-backed enum, an explicit state machine, or
  an event-backed model?
- Which transitions are valid, and which side effects belong to publish,
  withdraw, reverse withdrawal, rollover and copy?
- Are `withdrawn` and `rolled_over` publication states, separate course states,
  or workflow events?
- Should application opening remain a side effect of publication, or be an
  explicit independent action?
- Which model owns publishability validation and how should failures be shown
  to providers?
- If state is stored on `course`, should the column be named
  `publication_status`, `published_status`, `visibility_status` or something
  else? The name depends on the agreed semantics.
- Which scalar fields should move with publication state, and which performance
  improvements should be measured before and after the change?
- Should remaining content live on `course`, in a one-to-one content model, or
  in a more explicitly defined document?
- Is enrichment `created_by`/`updated_by` data required after migration, or can
  the audit system be authoritative?
- What historical content must be retained, and does it belong in the live
  course model or an archive?
- During migration, is transactional dual writing preferable to a coordinated
  write/read cutover for each group of fields? If dual writing is used, which
  copy is authoritative at each stage and how will drift be detected?
- What deterministic rule selects the effective values for historical courses
  with no enrichment, one enrichment, or several enrichments?
- How will Publish, Find, Saved courses, exports, alerts and the public API be
  verified against the same definition before legacy logic is removed?

## Related decisions

- [ADR 14. Recent Searches and Email Alerts for Find Teacher Training](0014-recent-searches-email-alert.md)
- [ADR 20. Find non-location course search](0020-find-non-location-course-search.md)
- [ADR 21. Find location course search](0021-find-location-course-search.md)
