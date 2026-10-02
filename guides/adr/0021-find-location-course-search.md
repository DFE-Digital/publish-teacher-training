# 21. Find location course search

Date: 22 September 2026

## Status

Accepted

## Context

Find also lets candidates search by place: a city, postcode, or other location, optionally with a radius. A course should appear if any of its attached schools is within that radius. The result is still one row per course, annotated with the distance to the nearest matching school.

Location search used to query duplicated `Site` rows. [ADR 16](0016-model-school-relationships-with-gias-backed-join-tables.md) moved school data to GIAS-backed relationships. Coordinates now live on `GiasSchool.geo_location`. Course-to-school links live on `course_school`. [ADR 18](0018-roll-out-school-relationship-model-with-dual-writes-and-feature-flags.md) and [ADR 19](0019-use-new-school-relationships-in-api-search-publishing-and-operations.md) rolled that model out behind `:course_publishing_uses_new_school_model`. That flag and the `Site` location query have since been removed. Location search reads `course_school` and `gias_school` only.

The shared Find pipeline — params, form, filters, findability, pagination — is documented in [ADR 20](0020-find-non-location-course-search.md). This ADR records the location-specific decisions: geocoding, radius, PostGIS filtering, and nearest-school display.

This ADR records the current implementation. It does not propose a behaviour change.

Public API location search (`CourseSearchService` / `CourseSearchServiceSchools`) is a separate stack and is only noted here as a related consumer.

## Options

### 1. Keep location search on `Site`

Continue joining `course_site` → `site` and measuring `ST_DistanceSphere` from `site.latitude` / `site.longitude`.

#### Pros

- No change to a query that already produced the expected product behaviour.
- No feature-flagged branch in `Courses::Query`.

#### Cons

- Search would keep reading duplicated, cycle-copied school-like `Site` rows.
- Distances would drift from GIAS as imported school coordinates change.
- The remodel’s purpose — GIAS as the school source — would not apply to Find’s most expensive query.

### 2. Query provider-school fallback when a course has no course schools

Join through `course_school` when present, otherwise fall back to the provider’s `provider_school` rows, matching the public API transition behaviour in [ADR 19](0019-use-new-school-relationships-in-api-search-publishing-and-operations.md).

#### Pros

- Courses that have provider schools but no course schools could still appear in a location search.

#### Cons

- Find results would mix course-specific placements with provider-level fallbacks.
- Product behaviour would change: a course could appear near a school it is not actually attached to.
- [ADR 19](0019-use-new-school-relationships-in-api-search-publishing-and-operations.md) asked search to keep equivalent product behaviour while changing the backing model.

### 3. Filter and sort by nearest `GiasSchool` on the course-school relationship

Geocode the candidate’s location, then include a course when any `course_school` → `gias_school` point is within the radius. Annotate the row with the minimum distance.

#### Pros

- Search reads the same GIAS-backed relationships as publishing and the API.
- The GiST index on `gias_school.geo_location` can prune far-away schools before the course join.
- Product behaviour stays “nearest attached school within radius, one row per course”.

#### Cons

- A published course with no geocoded course school disappears from location results even though it is findable without a location.
- Distance maths must stay aligned across the results card, course page and saved courses, or those surfaces will disagree.

## Decision

Use option 3. Location search is the same `Courses::Query` as [ADR 20](0020-find-non-location-course-search.md), with geocoding, radius defaults, and an extra location scope.

### When a search is located

Location mode is defined by present `latitude` and `longitude` (`Courses::SearchLocation#located?`), not by the raw `location` text. Text without coordinates is treated as a non-location search.

`Find::ResultsController` always calls `Geolocation::Address.query` with the `location` string. The resolver (`Geolocation::AddressResolver`) geocodes through `GoogleOldPlacesAPI::Client`, caches the result for 30 days, and wraps it in `Geolocation::Address` (coordinates, formatted and short address, country, Google `address_types`). Autocomplete on the location field uses `Geolocation::Suggestions` against the same client and cache TTL.

If geocoding fails, the error is logged and sent to Sentry, and the resolver returns blank coordinates. The candidate still sees results — they degrade to the [non-location path](0020-find-non-location-course-search.md) rather than an error page.

### Radius and default order

`Courses::DefaultRadius` chooses the initial radius from the geocoded address:

- 10 miles for locality-like Google types (postcode, street, route, locality);
- 20 miles for London;
- 50 miles otherwise.

The form only accepts 10, 20, 50 or 100 miles. `Courses::Query` itself falls back to 10 miles if a radius is missing or unreadable.

When the search is located, the default order is `distance`. The no-location default (`course_name_ascending`) is reset only on the first transition from no location to a location. Later drift in Google `address_types` (locality ↔ regional) must not silently override a sort the candidate just chose.

### How the location scope is built

`Courses::Query#location_scope` runs only when both coordinates are present. It filters and annotates distance through `course_school` and `gias_school`.

1. Build a geography point from the search longitude and latitude (SRID 4326).
2. In a derived table, join `gias_school` to `course_school` where `gias_school.geo_location` is present and `ST_DWithin(..., radius_in_metres, false)`.
3. `GROUP BY course_school.course_id` and take `MIN(ST_Distance(..., false))`.
4. Inner-join that derived table to `course`, select `minimum_distance_to_search_location` in miles, and group so subject joins and later orderings cannot duplicate or un-group the distance column.

The derived table exists so Postgres does not flatten the nearby-school work into a per-(school × course) join that then re-applies published-course filters. `ST_DWithin` can use the partial GiST index `index_gias_school_on_geo_location`. The trailing `false` on `ST_DWithin` / `ST_Distance` forces sphere maths. Miles conversion uses `Geolocation::METRES_PER_MILE` (`1609.344`).

### How results are built and displayed

The query still returns one course. `minimum_distance_to_search_location` is the nearest attached school inside the radius, calculated in `schools_location_scope`.

- Result cards (`Courses::SummaryCardComponent`) show that column, ceiled to a whole mile. The card does not run a second distance query.
- The course page (`Find::CoursesController`) uses `Courses::NearestSchoolQuery` for its own nearest-school distance. A course with no geocoded school is not an error; the page falls back to the funding hint.
- `?debug` uses `Courses::SchoolDistancesQuery` to list every school and its distance.

`NearestSchoolQuery` and `SchoolDistancesQuery` share `Courses::CanonicalSchoolDistance`. The results query does not. Its distance SQL is written in `schools_location_scope`. The three stay aligned only by using sphere maths and `Geolocation::METRES_PER_MILE`. A change in `CanonicalSchoolDistance` does not change the distance on the results card, and the other way around.

On the new model, `CanonicalSchoolDistance` reads `gias_school.geo_location` and labels main sites in SQL (`site_code = "-"`). `DISTINCT ON` plus `site_code` breaks ties when two provider schools share a GIAS school. `schools_location_scope` does not apply that tie-break: it keeps `MIN(ST_Distance(...))` per course and does not choose a school row.

A course with no geocoded course school is excluded from location results (inner join) but remains findable without a location, as in [ADR 20](0020-find-non-location-course-search.md).

When a location search returns nothing, `Courses::RadiusQuickLinkSuggestions` can offer larger-radius links by counting how many of the first 100 courses at the maximum radius fall inside each allowed radius.

### Saved courses are not the same query

`SavedCourses::Query` subclasses `Courses::Query` but does not use `schools_location_scope`. It annotates distance with its own `ST_DistanceSphere` SQL. It does not filter by radius, and it keeps previous-cycle saved courses even when their old placement sites are no longer publishable. A change to `location_scope` or `CanonicalSchoolDistance` does not change the saved-courses page.

### Data sources

Current location search reads:

- `gias_school.geo_location` — stored generated geography point, null when either coordinate is missing, indexed by a partial GiST index;
- `course_school` — which schools are attached to the course;
- `provider_school` — display name, main-site label, and UUID on nearest-school / debug queries.

Coordinates come from `gias_school`. `Site` remains the study-placement model.

## Consequences

Location search now queries a smaller, GIAS-backed relationship instead of cycle-copied `Site` rows. School coordinate updates from the GIAS import can flow through to Find without rewriting copied site records.

Product behaviour stays “one course, nearest attached school, within radius”. Engineers can trace that contract from geocoding through `location_scope` to the card, course page and debug panel.

Location search reads `course_school` and `gias_school` only. The feature-flagged `Site` path has been removed.

Location results are a subset of findable courses: published courses without a geocoded course school will not appear. That is expected. Widen or remove the location filter to see them.

Geocoding is a runtime dependency. Cache hits keep most requests off the Google client. A cache miss or client failure must not 500 the results page.

Distance is not calculated in one place. The results card reads `minimum_distance_to_search_location` from its own `ST_Distance(..., false)` in `Courses::Query#schools_location_scope`. The course page and the debug panel use `CanonicalSchoolDistance`. `SavedCourses::Query` has its own `ST_DistanceSphere` copy over `gias_school` coordinates. Changing only `CanonicalSchoolDistance` leaves the results card on the old maths, so the card and the course page can show different distances for the same course. Sphere maths and `Geolocation::METRES_PER_MILE` are the shared contract. The nearest-school tie-break exists only in `CanonicalSchoolDistance`.

Public API location search is still `CourseSearchServiceSchools`, not `Courses::Query`. Equivalent product behaviour there is a separate change.

## Related decisions

- [ADR 14. Recent Searches and Email Alerts for Find Teacher Training](0014-recent-searches-email-alert.md)
- [ADR 16. Model school relationships with GIAS-backed join tables](0016-model-school-relationships-with-gias-backed-join-tables.md)
- [ADR 18. Roll out school relationship changes with dual writes and feature flags](0018-roll-out-school-relationship-model-with-dual-writes-and-feature-flags.md)
- [ADR 19. Use new school relationships in API, search, publishing and operations](0019-use-new-school-relationships-in-api-search-publishing-and-operations.md)
- [ADR 20. Find non-location course search](0020-find-non-location-course-search.md)
