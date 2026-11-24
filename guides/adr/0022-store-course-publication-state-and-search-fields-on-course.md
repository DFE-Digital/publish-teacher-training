# 22. Course publication state and CourseEnrichment

Date: 20 October 2026

Last updated: 24 November 2026

## Status

Proposed

## Context

Providers used to edit a separate draft while the published version stayed
live. Publishing replaced the live version with the draft. Providers now edit
the published content in place, and the `DeleteSubsequentDraftEnrichments`
migration removed the old drafts with unpublished changes. Some older courses
can still have more than one enrichment.

This ADR looks at where to store publication state and what to do with
`CourseEnrichment`. Once the team picks a direction, a follow-up ADR can cover
which fields to move, how to split the work and how to migrate existing data.

## Problems raised by the development team

### CourseEnrichment data model

#### Older versions make it hard to pick the right row

A course can still have several enrichment rows with different statuses.
Different parts of the app use different rules to decide which row is
"latest", so the row they use can vary.

#### Course and enrichment are tightly coupled

Many features need data from both the course and its enrichment. For example,
Find uses subqueries, lateral joins and eager loading to read one course's
status and content.

#### JSON fields have fewer database constraints

Most enrichment content lives in one JSON column, so those fields lack their
own column types and constraints. The JSON uses older names such as
`FeeUkEu`, and `course_length` is stored as free text even though it has a
set of standard values.

#### Find reads fees and interview location from JSON

Find has to pick an enrichment row and extract JSON values to filter, sort
and display results. Sorting by fees also requires casting the values to
integers.

#### The API can drift from the model

The API maps enrichment fields separately. When a field changes, its API
mapping may need an update too.

#### Enrichments duplicate audit information

Enrichments store who created and updated them. The app already has an audit
system that could track who made changes in the replacement model.

### Publishing flow

#### There is no single source of truth for publication state

The course methods, Publish list, Find and the API can disagree on whether a
course is published or visible.

#### Publishing does several things at once

`PublishService` publishes draft or rolled-over enrichments, undiscards the
course and opens applications. It also sets the first publication time and
records who published the enrichment and when.

#### Publication rules are spread across workflows

To see when a course can change state and what happens when it does, you have
to read several workflows. Similar action names make those rules harder to
follow.

#### Validation and feedback are spread across models

Publish checks run on the course and related models. Older enrichment rows
can affect those checks. With the rules spread out, it's harder to tell
providers what they need to fix before they can publish.

#### Lifecycle actions reuse the content table

Rollover and withdrawal use enrichment statuses to track what happened to
the course. Withdrawal also suspends legacy site statuses.

#### Several workflows maintain the publication timestamp

Code that changes a course has to update the right timestamp. Code that
shows the last-published or last-updated date has to know which record and
timestamp to read.

## Current behaviour and query dependencies

`Course#content_status` uses `Courses::ContentStatusService`. The Publish
course list repeats the logic in a SQL `CASE` expression. Find and reporting
check for a published enrichment and can exclude a course based on the
status of its latest enrichment.

| Use | Current enrichment dependency |
| --- | --- |
| Find visibility | Enrichment status and legacy multi-row rules |
| Interview-location filter | `InterviewLocation` from enrichment JSON |
| Newest ordering and weekly alerts | `last_published_timestamp_utc` |
| UK and international fee ordering | JSON extraction and integer casts |
| Result-card fees | Preloaded latest published enrichment |

Saved courses use some of the same status, ordering and fee lookups. Course
pages and the public API also read the long-form content.

Other fields and rules answer separate questions about the course.

- `application_status` says whether a published course accepts applications.
- A published course in a future cycle can appear as scheduled.
- `discarded_at` records deletion.
- Find visibility is independent of site status and vacancy data.

## Decision drivers

- Use one source of truth for publication state.
- Make it clear which actions change publication state and what else they do.
- Keep publication, application availability, scheduling and deletion as
  separate concepts.
- Remove the need to pick a version of the content at runtime.
- Reduce joins, JSON extraction and duplicated status logic on Find and Saved
  course paths.
- Use typed columns and constraints for fields we query often.
- Keep common course queries from loading long-form content they don't use.
- Keep the public API compatible and make any version changes explicit.
- Keep the audit and historical data we need.
- Define how to migrate courses with zero, one or several enrichments.
- Support a safe transition while providers continue editing and publishing
  courses.

## Options

### 1. Keep publication and all content on CourseEnrichment

Keep the current model. This avoids a migration and leaves the existing
status rules, version selection and search queries in place.

### 2. Move only publication state to Course

Store publication state on `Course`. This is the smallest change that simplifies
Find visibility and the Publish course list. Find still reads enrichments for
fees, interview location and newest ordering.

### 3. Move publication and search-facing fields first

Move publication state and some fields used by Find onto `Course`. Storing
fees, interview location or the last-published timestamp in typed columns
could simplify filters, sorting and result cards. This is more work up front
than moving state alone. Course pages and the API still read the enrichment
for content.

### 4. Move all enrichment fields to Course

Move publication state and all current content onto `Course`, then retire
`CourseEnrichment`. All current course data would live in one place. This
requires a wider content and API migration, and queries that load the full
course row would also load its long-form content.

### 5. Replace CourseEnrichment with a non-versioned content model

Keep publication state on `Course` and replace `CourseEnrichment` with one
content record per course. This removes version selection and keeps long-form
content off the main course row. Course pages and the API still need to load
that content record.

Options 2 and 3 describe possible first steps. Either could lead to option 4
or 5.

### How publication could work on Course

- Use AASM, which we already use on `SiteStatus`, to manage a text column
  with four proposed values (`draft`, `rolled_over`, `published` and
  `withdrawn`). The team can choose the column name and decide whether to
  keep `rolled_over` as a state or track it with a separate flag.
- Publish a `draft` or `rolled_over` course, withdraw a `published` course, and
  restore a `withdrawn` course to `published`. A normal copy starts in `draft`.
  A rollover creates a new course in `rolled_over` under the four-state
  proposal. `draft` is a starting state only.
- Find search results include only published courses from the current
  recruitment cycle and still apply the existing deletion checks. Application
  status stays separate. Publishing a course in the current cycle opens
  applications.
- Keep `Course#publishable?` as the entry point for publish checks. The
  checks could live in a concern. Use the audit system to track who made
  changes when we replace the enrichment audit fields.

### Rollout preference

If the team chooses to move data, the preference is to switch once and avoid
dual writes. Merge the new code behind a feature flag, migrate the data, then
enable the new reads, writes and validations together. Add comments to the
legacy code so it's easy to find and remove after the switch. The follow-up
ADR can cover field mapping, backfill, retention, verification and rollback.

## Related decisions

- [ADR 14. Recent Searches and Email Alerts for Find Teacher Training](0014-recent-searches-email-alert.md)
- [ADR 20. Find non-location course search](0020-find-non-location-course-search.md)
- [ADR 21. Find location course search](0021-find-location-course-search.md)
