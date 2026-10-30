# Data Dictionary

A reference of all database tables and their corresponding ActiveRecord models. Each heading uses the model class name. The table name is noted where it differs from the Rails convention.

For the full schema definition see [`db/schema.rb`](../db/schema.rb).

---

## RecruitmentCycle

**Table:** `recruitment_cycle`
**Model:** [`app/models/recruitment_cycle.rb`](../app/models/recruitment_cycle.rb)

A recruitment cycle represents one academic year of teacher training. Each cycle has an application start date and end date. Providers and their courses belong to a specific recruitment cycle. The `year` column stores the cycle year as a string (e.g. `"2026"`). Use `RecruitmentCycle.current` to get the active cycle.

---

## Provider

**Table:** `provider`
**Model:** [`app/models/provider.rb`](../app/models/provider.rb)

A training provider that offers courses. Providers belong to a `RecruitmentCycle`. The `provider_code` is unique within each cycle.

Providers have a `provider_type` enum: `scitt`, `lead_school`, or `university`. The `accredited` boolean marks whether the provider is an accredited initial teacher training provider. Accredited providers can accredit courses run by other providers.

Providers support full-text search via `pg_search` on `provider_name` and `provider_code`. The `searchable` tsvector column is maintained automatically for accredited providers.

Soft-deleted via `Discard::Model` using the `discarded_at` column.

---

## Course

**Table:** `course`
**Model:** [`app/models/course.rb`](../app/models/course.rb)

A teacher training course offered by a provider. This is the central entity of the service. Each course has a `course_code` unique within its provider.

Key attributes:

- `funding`: `fee`, `salary`, or `apprenticeship`
- `degree_type`: `postgraduate` or `undergraduate`
- `qualification`: the award on completion (e.g. QTS, PGCE with QTS)
- `study_mode`: full-time, part-time, or both
- `application_status`: `open` or `closed`
- `program_type`: legacy UCAS programme type code
- `accredited_provider_code`: links to the accrediting provider by code
- `master_subject_id`: the primary subject for the course

Soft-deleted via `Discard::Model` using `discarded_at`. Audited via the `audited` gem.

---

## CourseEnrichment

**Table:** `course_enrichment`
**Model:** [`app/models/course_enrichment.rb`](../app/models/course_enrichment.rb)

Stores the editorial content for a course. Each enrichment record belongs to a `Course` and has a `status` enum: `draft`, `published`, `rolled_over`, or `withdrawn`.

Most content fields are stored in the `json_data` JSONB column and accessed via `jsonb_accessor`. Fields include `about_course`, `fee_details`, `fee_uk_eu`, `fee_international`, `salary_details`, `how_school_placements_work`, and `interview_process`.

A course can have multiple enrichment records. The most recent published record is the live version shown on Find. Tracks which user created and last updated each enrichment.

---

## Site

**Table:** `site`
**Model:** [`app/models/site.rb`](../app/models/site.rb)

A physical location associated with a provider. The `site_type` enum distinguishes between `school` (a placement school) and `study_site` (where theoretical training happens).

Each site has an address, postcode, and optional coordinates for geolocation. Sites are geocoded automatically after commit. The `code` column is a short alphanumeric identifier unique within the provider.

Soft-deleted via `Discard::Model` using `discarded_at`. This is a legacy model. New school data uses `Provider::School` and `GiasSchool` instead.

---

## SiteStatus

**Table:** `course_site`
**Model:** [`app/models/site_status.rb`](../app/models/site_status.rb)

Join table between `Course` and `Site`. Tracks the status and vacancy information for a course at a specific site.

- `status`: `running`, `new_status`, `suspended`, or `discontinued`
- `publish`: `published` or `unpublished`
- `vac_status`: vacancy availability (full-time, part-time, both, or none)

Uses AASM for state machine transitions. A site status is "findable" when it is both running and published.

---

## GiasSchool

**Table:** `gias_school`
**Model:** [`app/models/gias_school.rb`](../app/models/gias_school.rb)

A school record imported from the Get Information About Schools (GIAS) register. Identified by `urn` (unique reference number). Contains address, coordinates, phase, and status information.

The `status_code` enum includes `open`, `closed`, `proposed_to_close`, and `proposed_to_open`. The `geo_location` column is a PostGIS geography point generated from latitude and longitude. Supports full-text search via a `searchable` tsvector column.

---

## Provider::School

**Table:** `provider_school`
**Model:** [`app/models/provider/school.rb`](../app/models/provider/school.rb)

Links a `Provider` to a `GiasSchool`. Each record represents a school that a provider has added to their account. The `site_code` column is a short identifier. A code of `"-"` marks the provider's main site. Only one main site is allowed per provider.

Delegates address fields to the associated `GiasSchool`.

---

## Course::School

**Table:** `course_school`

Join table between `Course` and `Provider::School`. Records which schools are assigned to a course. Also references the `GiasSchool` directly for query performance.

---

## StudySitePlacement

**Table:** `study_site_placement`
**Model:** [`app/models/study_site_placement.rb`](../app/models/study_site_placement.rb)

Join table between `Course` and `Site`. Links a course to a study site. Validates that the site must not be of type `school`.

---

## Subject

**Table:** `subject`
**Model:** [`app/models/subject.rb`](../app/models/subject.rb)

A teaching subject (e.g. Mathematics, English, Physics). Uses single-table inheritance via the `type` column: `PrimarySubject`, `SecondarySubject`, `ModernLanguagesSubject`, or `DiscontinuedSubject`.

Each subject has a `subject_code` and belongs to a `SubjectArea`. Optionally belongs to a `SubjectGroup`. The `match_synonyms` array stores alternative names used for search matching.

---

## SubjectArea

**Table:** `subject_area`
**Model:** [`app/models/subject_area.rb`](../app/models/subject_area.rb)

Groups subjects into broad areas. Uses `typename` as the primary key (matches the `type` column on `Subject`). Has many subjects.

---

## SubjectGroup

**Table:** `subject_group`
**Model:** [`app/models/subject_group.rb`](../app/models/subject_group.rb)

Groups related secondary subjects together for display purposes. Has many subjects.

---

## CourseSubject

**Table:** `course_subject`
**Model:** [`app/models/course_subject.rb`](../app/models/course_subject.rb)

Join table between `Course` and `Subject`. The `position` column determines the ordering of subjects on a course. Unique on `course_id` and `subject_id`.

---

## FinancialIncentive

**Table:** `financial_incentive`
**Model:** [`app/models/financial_incentive.rb`](../app/models/financial_incentive.rb)

Stores bursary and scholarship amounts for a subject in a given year. Belongs to a `Subject`. Each subject can have one `displayed` incentive record per year, which is the one shown to candidates.

Fields include `bursary_amount`, `scholarship`, `early_career_payments`, and flags for non-UK eligibility and SKE course availability.

---

## User

**Table:** `user`
**Model:** [`app/models/user.rb`](../app/models/user.rb)

A provider user or support user on Publish. Authenticated via DfE Sign-in.

- `admin`: marks the user as a DfE support user. Admin users must have an `@education.gov.uk` or `@digital.education.gov.uk` email.
- `blazer_access`: grants access to Blazer analytics dashboards. Only applies to admin users.
- `accept_terms_date_utc`: timestamp when the user accepted the Publish terms.
- `magic_link_token`: used for fallback authentication when DfE Sign-in is unavailable.

Users are not soft-deleted. When a support user deletes a user, the record is removed from the database (`destroy!`). The `discarded_at` column is a leftover from when users were soft-deleted. The `User` model no longer uses `Discard`, so do not rely on this column. Supports full-text search on `first_name`, `last_name`, and `email`.

---

## UserPermission

**Table:** `user_permission`
**Model:** [`app/models/user_permission.rb`](../app/models/user_permission.rb)

Join table between `User` and `Provider`. Grants a user access to a provider's courses and settings. There are no granular permission flags. If a record exists, the user has full access to that provider.

---

## UserNotification

**Table:** `user_notification`
**Model:** [`app/models/user_notification.rb`](../app/models/user_notification.rb)

Stores a user's notification preferences for a provider. Linked to `Provider` via `provider_code`. The `course_publish` and `course_update` booleans control whether the user receives email notifications when courses are published or updated.

---

## Candidate

**Table:** `candidate`
**Model:** [`app/models/candidate.rb`](../app/models/candidate.rb)

A candidate who uses the Find service. Authenticated via GOV.UK One Login. Identified by `email_address`. Candidates can save courses and set up email alerts. Candidates cannot access Publish or the Support Console.

---

## Candidate::EmailAlert

**Table:** `candidate_email_alerts`
**Model:** [`app/models/candidate/email_alert.rb`](../app/models/candidate/email_alert.rb)

An email alert subscription for a candidate. Stores search criteria (subjects, location, radius) in the `search_attributes` JSONB column. A candidate can have up to 10 active alerts. Alerts are deactivated by setting `unsubscribed_at`.

---

## SavedCourse

**Table:** `saved_course`
**Model:** [`app/models/saved_course.rb`](../app/models/saved_course.rb)

Join table between `Candidate` and `Course`. Represents a course a candidate has saved on Find. The `note` field allows the candidate to store a personal note (up to 100 words). Unique on `candidate_id` and `course_id`.

---

## RecentSearch

**Table:** `candidate_recent_search`
**Model:** [`app/models/recent_search.rb`](../app/models/recent_search.rb)

Stores a candidate's recent search criteria on Find. Belongs to a `Candidate` (via `find_candidate_id`). Stores subjects, location coordinates, radius, and additional search attributes.

Soft-deleted via `Discard::Model` using `discarded_at`. Stale searches older than 30 days are cleaned up.

---

## Authentication

**Table:** `authentication`
**Model:** [`app/models/authentication.rb`](../app/models/authentication.rb)

Stores authentication credentials for users and candidates. Polymorphic via `authenticable_type` and `authenticable_id`. The `provider` enum indicates the identity provider: `developer`, `govuk_one_login`, or `dfe_signin`. The `subject_key` stores the unique identifier from the identity provider.

---

## Session

**Table:** `session`
**Model:** [`app/models/session.rb`](../app/models/session.rb)

Stores active user sessions. Polymorphic via `sessionable_type` and `sessionable_id` (links to either `User` or `Candidate`). Sessions expire after 30 minutes of inactivity. The `data` JSONB column stores session-specific data.

---

## Contact

**Table:** `contact`
**Model:** [`app/models/contact.rb`](../app/models/contact.rb)

Contact details for a provider. Belongs to a `Provider`. The `type` enum defines the contact role: `admin`, `utt`, `web_link`, `fraud`, or `finance`. Each provider can have one contact per type.

---

## Organisation

**Table:** `organisation`
**Model:** [`app/models/organisation.rb`](../app/models/organisation.rb)

A legacy organisational grouping. Links users to providers via `OrganisationUser` and `OrganisationProvider`. Identified by `org_id`.

---

## OrganisationUser

**Table:** `organisation_user`
**Model:** [`app/models/organisation_user.rb`](../app/models/organisation_user.rb)

Join table between `Organisation` and `User`. Unique on `organisation_id` and `user_id`.

---

## OrganisationProvider

**Table:** `organisation_provider`

Join table between `Organisation` and `Provider`. No dedicated model file — accessed via `has_and_belongs_to_many` on both sides.

---

## ProviderPartnership

**Table:** `provider_partnership`
**Model:** [`app/models/provider_partnership.rb`](../app/models/provider_partnership.rb)

Links a training provider to an accredited provider. Validates that the accredited provider has `accredited: true` and that the training provider does not. Unique on the pair of provider IDs.

---

## ProviderUCASPreference

**Table:** `provider_ucas_preference`
**Model:** [`app/models/provider_ucas_preference.rb`](../app/models/provider_ucas_preference.rb)

Legacy UCAS preferences for a provider. Stores settings for application alert emails and GT12 response handling. Each provider has one record.

---

## ProvidersOnboardingFormRequest

**Table:** `providers_onboarding_form_request`
**Model:** [`app/models/providers_onboarding_form_request.rb`](../app/models/providers_onboarding_form_request.rb)

A request from a new provider to be onboarded onto Publish. Created by a support agent and sent to the provider to complete. The `status` enum tracks the request lifecycle: `pending`, `submitted`, `expired`, `closed`, or `rejected`.

Stores the provider's details (name, UKPRN, URN, address, contact information) and a link to the associated Zendesk ticket. Optionally assigned to a `User` (support agent) via `support_agent_id`.

---

## Feedback

**Table:** `feedback`
**Model:** [`app/models/feedback.rb`](../app/models/feedback.rb)

User feedback submitted through the Find service. Stores an `ease_of_use` rating and free-text `experience` field (max 1200 characters).

---

## Statistic

**Table:** `statistic`
**Model:** [`app/models/statistic.rb`](../app/models/statistic.rb)

Stores aggregate statistics as JSON in the `json_data` column. Minimal model with no associations or validations.

---

## Banner

**Table:** `banner`
**Model:** [`app/models/banner.rb`](../app/models/banner.rb)

A message shown to users at the top of a service.

- `name`, `heading` and `body`: the banner text.
- `published_at` and `expired_at`: the dates when the banner starts and stops showing.
- `display_on_find`, `display_on_publish`, `display_on_support`: choose which services show the banner. At least one must be true.

---

## FeatureFlagState

**Table:** `feature_flag_state`
**Model:** [`app/models/feature_flag_state.rb`](../app/models/feature_flag_state.rb)

Stores whether a feature flag is on or off. `name` is unique and `active` is the on/off value.

---

## SiteSetting

**Table:** `site_setting`
**Model:** [`app/models/site_setting.rb`](../app/models/site_setting.rb)

A named setting with a text `value`. `name` is unique and must be one of `SiteSetting::NAMES` (for example `cycle_schedule`).

---

## Course::SchoolBulkUpdateDraft

**Table:** `course_school_bulk_update_draft`
**Model:** [`app/models/course/school_bulk_update_draft.rb`](../app/models/course/school_bulk_update_draft.rb)

A temporary draft used when a user changes the schools of a course in bulk. It belongs to a `Course` and a `User`.

- `school_uuids`: the schools chosen in the draft.
- `baseline_uuids`: the schools the course had when the draft was started.
- `expires_at`: when the draft is no longer valid.

---

## CourseIncentive

**Model:** [`app/models/course_incentive.rb`](../app/models/course_incentive.rb)

Not backed by a database table. A plain Ruby class that calculates bursary and scholarship amounts for a course based on its subjects and their `FinancialIncentive` records. Instantiated with a `Course` and queried for funding information.

---

## Infrastructure tables

The following tables support framework functionality. They are not part of the application domain.

### Blazer tables

`blazer_queries`, `blazer_dashboards`, `blazer_dashboard_queries`, `blazer_checks`, `blazer_audits` — managed by the [Blazer](https://github.com/ankane/blazer) gem for SQL-based analytics dashboards.

### Audit

`audit` — managed by the [Audited](https://github.com/collectiveidea/audited) gem. Stores change history for audited models.

### DataMigrations

`data_migrations` — tracks one-off data migration scripts. Uses a `version` string as the primary key.

### Solid Queue and Solid Cache

`solid_queue_*` tables — managed by [Solid Queue](https://github.com/rails/solid_queue). This is how the app runs background jobs.

`solid_cache_entries` — managed by [Solid Cache](https://github.com/rails/solid_cache). This is where the app stores its cache.

### DelayedJobs (leftover)

`delayed_jobs` — a leftover from [Delayed Job](https://github.com/collectiveidea/delayed_job), which the app used before Solid Queue. The app no longer uses it for background jobs.

### DataHubProcessSummary

`data_hub_process_summary` — tracks the status and results of batch data processing operations. Uses single-table inheritance via the `type` column.

### EFMigrationsHistory

`__EFMigrationsHistory` — a legacy table from an earlier .NET version of the application. Not used by the Rails application.
