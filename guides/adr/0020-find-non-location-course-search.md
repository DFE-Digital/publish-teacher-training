# 20. Find non-location course search

Date: 22 September 2026

## Status

Accepted

## Context

Find is the candidate-facing service for discovering teacher training courses. Search is its core journey: a candidate starts from the homepage, a subject page, or the results filters, and the service must return current-cycle published courses that match those filters.

Not every search has a place. Candidates often search by subject, visa sponsorship, funding, degree requirement or provider with no location at all. After the schools data remodel, school coordinates live on `GiasSchool` and relationships live on `course_school` / `provider_school`. Non-location search must not depend on that school data. A published course with no attached schools is still findable.

We need a single, documented query path so engineers maintaining Find in run state can see:

- how a request becomes a result set;
- which objects own params, defaults, filtering and ordering;
- what “findable” means after the remodel; and
- how this path differs from [location-based search](0021-find-location-course-search.md).

This ADR records the current implementation. It does not propose a behaviour change.

Public API search (`CourseSearchService` / `CourseSearchServiceSchools`) is a separate stack. Location-based API search is covered at a high level by [ADR 19](0019-use-new-school-relationships-in-api-search-publishing-and-operations.md). Publish and Support school-name search is out of scope.

## Options

### 1. Build the result set in the controller

`Find::ResultsController` would permit params, apply ActiveRecord scopes on `Course`, and paginate the relation itself.

#### Pros

- Few extra classes.
- Easy to see the query next to the action.

#### Cons

- The same filter and findability rules are needed by email alerts, recent-search replay and local query logging.
- Controllers become hard to test in isolation.
- Location and non-location SQL would both land in the same action.

### 2. Separate query services for location and non-location search

A `Courses::NonLocationQuery` would own filters and name ordering. A separate location query would own distance SQL.

#### Pros

- Each class would only contain the SQL it needs.
- Location joins would never leak into an unlocated search.

#### Cons

- Every new filter (visa, funding, degree, start date, …) would have to be added twice.
- Email alerts and recent searches would have to pick a service, or we would still need a shared core.
- Default-order rules that depend on whether a location is present would sit awkwardly between the two classes.

### 3. One query object with location as an optional scope

A single `Courses::Query` starts from current-cycle published courses and stacks named filter and order scopes. Location is one optional scope. The controller and form stay thin.

#### Pros

- Filters live in one place and apply to both search modes.
- Email alerts and recent-search replay can reuse the same query.
- Location SQL is isolated in `location_scope` and does not run when coordinates are absent.
- Findability is defined once and stays independent of school presence.

#### Cons

- `Courses::Query` is a large class.
- Engineers must know that location is skipped unless `latitude` and `longitude` are present.
- Ordering scopes that add `GROUP BY` have to stay compatible with the optional location join.

## Decision

Use one query object, `Courses::Query`, for Find search. Location is an optional scope. This ADR documents the path that runs when there is no geocoded location. [ADR 21](0021-find-location-course-search.md) documents the location path.

### Request flow

1. The candidate starts from the Find homepage (`Find::HomepageController`), a primary or secondary subject page, or the results filters.
2. `GET /results` is handled by `Find::ResultsController`.
3. `Find::SearchParams` permits the query keys the form and query understand.
4. `Geolocation::Address.query` still runs against the `location` param. With no usable location it returns blank coordinates, so the search stays on this path.
5. `Courses::SearchForm` applies defaults (degree “show all”, level, order) and exposes filter counts for the results UI.
6. `Courses::Query` builds the relation. `Courses::Query#count` then `Pagy` paginate it.
7. Each page of courses is rendered as `Courses::SummaryCardComponent`.

`Courses::SearchLocation` answers whether the search is located (`latitude` and `longitude` present). `Courses::OrderingStrategy` uses that to pick the default sort. On this path the search is not located.

### Base scope and findability

`Courses::Query` starts from:

- `course` rows that are not discarded;
- an inner join to the current recruitment cycle’s non-discarded `provider` rows; and
- `findable_courses_sql`, which mirrors `Course#is_published?`.

A course is findable when it has a published enrichment and its latest enrichment is not rolled over or withdrawn. That pair keeps a course findable if a legacy subsequent draft is still present, while excluding draft-only, rolled-over and withdrawn courses.

School presence does not affect findability. `publish_without_schools_allowed` does not affect findability either. A published salaried or apprenticeship course with no schools is returned on the same terms as any other published course. Study sites alone are not required for Find.

### Filters

The controller does not build SQL. `Courses::Query#call` stacks named scopes, each of which no-ops when its param is blank:

- visa sponsorship (`can_sponsor_student_visa` or `can_sponsor_skilled_worker_visa`);
- Engineers Teach Physics campaign;
- subjects / subject code (also drives master-subject ordering);
- study mode;
- interview location (online or both, from the latest published enrichment);
- qualification;
- further education level;
- minimum degree required;
- applications open;
- SEND;
- funding;
- start date ranges;
- provider code or name (training or accredited provider);
- excluded courses.

`optimisation_scope` preloads `site_statuses`, `schools`, the latest published enrichment, the provider, and subjects with financial incentives so result cards do not N+1.

### Ordering and result shape

When there is no location, the default order is `course_name_ascending` (`Courses::OrderingStrategy`). Distance order is rejected if there are no coordinates, so a stale `order=distance` query string cannot break the page.

Other explicit orders (provider name, newest, start date, UK or international fee) still apply. Master-subject ordering runs first when the candidate searched for subjects, so courses whose master subject matches the search appear before courses that only include that subject as a secondary.

Results are one row per course, not per school. Cards show a placement hint rather than a distance. Pagination uses Pagy. The total is `unscope(:order, :group).distinct.count(:id)` so subject or enrichment joins do not inflate the count.

### Data sources

Non-location search reads:

- `course`
- `provider`
- `course_enrichment` (publication and some filters / fee ordering)
- `subject` / `course_subject`

It does not join `course_school`, `gias_school` or `site`. Those tables are only used once coordinates are present, as described in [ADR 21](0021-find-location-course-search.md).

### Reuse

[ADR 14](0014-recent-searches-email-alert.md) stores recent searches and email-alert filters, then replays them through `Courses::Query`. New filters added here apply to alerts automatically.

## Consequences

Find search, email alerts and recent-search replay share one definition of “matching course”. A filter change cannot silently apply to the results page but not to weekly alerts.

Non-location search stays independent of the school remodel. Published courses without schools remain findable. Location search can change backing tables without rewriting this path.

`Courses::Query` is the place to change Find filtering and findability. That keeps the controller thin, but the class is large and ordering scopes must stay compatible with the optional location join documented in [ADR 21](0021-find-location-course-search.md).

Public API search is not this query. Changes to Find filters do not automatically change `CourseSearchService`.

## Related decisions

- [ADR 14. Recent Searches and Email Alerts for Find Teacher Training](0014-recent-searches-email-alert.md)
- [ADR 16. Model school relationships with GIAS-backed join tables](0016-model-school-relationships-with-gias-backed-join-tables.md)
- [ADR 19. Use new school relationships in API, search, publishing and operations](0019-use-new-school-relationships-in-api-search-publishing-and-operations.md)
- [ADR 21. Find location course search](0021-find-location-course-search.md)
