# ADR: Recent Searches and Email Alerts for Find Teacher Training

**Status:** Proposed
**Date:** 2026-02-16
**Authors:** Tomas
**Deciders:** Find and Publish Team

---

## Context

Candidates using the Find teacher training service frequently lose track of their search filters when navigating away from results. User research has identified two key pain points:

1. **Lost search state** — candidates must re-apply filters each time they return, causing frustration and drop-off.
2. **No proactive notifications** — candidates have no way to be alerted when new courses matching their criteria are published.

We need to introduce **Recent Searches** (saving and replaying search filter sets) and **Email Alerts** (weekly notifications when new matching courses appear). Both features are scoped to authenticated candidates behind the existing `:candidate_accounts` feature flag infrastructure.

---

## Decision

### 1. Store search filters as JSONB + denormalised dedup columns

**We will** create two new tables — `recent_searches` and `email_alerts` — that store the full set of search filters in a `search_attributes` JSONB column, with `subjects` (array), `latitude`, `longitude`, and `radius` as dedicated columns used for deduplication indexing.

**Alternatives considered:**

| Alternative | Why rejected |
|---|---|
| Normalised filter tables (one row per filter per search) | High write amplification, complex joins to reconstruct a search, no meaningful query benefit since we never filter searches by individual attributes |
| Store only a URL/query string | Fragile — URL structure changes break stored searches; no ability to validate or query individual filter values |
| Store everything in JSONB (including subjects/location) | Cannot build a performant unique partial index on JSONB subkeys for deduplication |

**Consequences:**
- Adding a new filter requires only adding the key to `SearchAttributesValidator::PERMITTED_KEYS` — no migration.
- Old records missing a new filter key work correctly (they simply don't filter on it).
- The unique partial index on `[candidate_id, subjects, longitude, latitude, radius] WHERE discarded_at IS NULL` prevents duplicate active searches efficiently.

### 2. Replay stored searches through `Courses::Query` for email alert matching

**We will** reuse the existing `Courses::Query` to match new courses against email alert criteria, rather than building a separate matching engine.

**Alternatives considered:**

| Alternative | Why rejected |
|---|---|
| Dedicated matching query/service | Duplicates complex filter logic (15+ filter types, PostGIS distance, degree grade cascading); guaranteed to drift from the actual search behaviour over time |
| Database triggers / materialised views | Overly complex for weekly batch processing; harder to test and debug; couples business logic to database layer |
| External search engine (Elasticsearch) | Not in the current stack; introduces operational overhead for a feature that runs once per week |

**Consequences:**
- Email alerts are guaranteed to match exactly what candidates see when they search manually.
- New filters added to `Courses::Query` automatically apply to email alerts.
- Weekly job iterates over active alerts and runs one `Courses::Query.call` per alert, scoped to courses published in the last week. For the expected alert volume (low thousands), this is acceptable. If alert volume grows significantly, we can batch or parallelise.

### 3. Use Discard gem for soft-delete on recent searches (undo flow)

**We will** use the Discard gem's `discarded_at` timestamp pattern for the "clear all" + undo flow on recent searches.

**Alternatives considered:**

| Alternative | Why rejected |
|---|---|
| Hard delete + store deleted IDs in session for undo | Requires re-inserting rows with original timestamps, which is error-prone and may violate unique constraints |
| Client-side undo (don't hit server until confirmed) | Doesn't survive page refresh or navigation; inconsistent with the app's server-rendered architecture |
| Dedicated "trash" table | Unnecessary complexity; Discard is already a dependency used elsewhere in the codebase |

**Consequences:**
- "Clear all" sets `discarded_at` on matching records; undo nullifies it.
- A daily cleanup job permanently deletes discarded records older than 1 day and any records (active or discarded) not updated in 30 days.
- The `discarded_at` column is included in the unique partial index condition, so discarded searches don't block new ones with the same filters.

### 4. Use Rails `signed_id` for email unsubscribe tokens

**We will** use Rails' built-in `signed_id` (via `ActiveRecord::SignedId`) to generate secure, expiring unsubscribe links in email alerts, rather than storing tokens in a separate table.

**Alternatives considered:**

| Alternative | Why rejected |
|---|---|
| Dedicated `unsubscribe_tokens` table | Additional table, migration, and cleanup job for something Rails provides out of the box |
| UUID column on `email_alerts` | No expiry mechanism; requires custom lookup; less secure than signed/encrypted tokens |
| Require authentication to unsubscribe | Poor UX — forces candidates to log in just to unsubscribe, which may violate email best practices |

**Consequences:**
- Unsubscribe links are stateless (no database lookup to validate, only signature verification).
- Tokens expire after 30 days (configurable), after which the candidate must log in to manage alerts.
- No additional tables or cleanup jobs needed.

### 5. Separate feature flags for independent rollout

**We will** ship recent searches under the existing `:candidate_accounts` flag and email alerts under a new `:email_alerts` flag.

**Rationale:**
- Recent searches are a natural extension of the candidate account (like saved courses) and can ship first.
- Email alerts involve external email delivery, GOV.UK Notify integration, and weekly background processing — higher risk, needs independent control.
- Both flags can be toggled independently without code changes.

### 6. Shared `SearchAttributesValidator` as single source of truth

**We will** create a validator class whose `PERMITTED_KEYS` constant is the canonical list of allowed search filter keys, shared between:
- `RecentSearch` model validation
- `EmailAlert` model validation
- Potentially the query module for consistency checks

**Rationale:**
- The spec explicitly calls for "a dedicated validation module as a single source of truth".
- Prevents silent data corruption from storing unsupported filter keys.
- When a new filter is introduced, adding it to one constant enables it everywhere.

### 7. `after_action` for recording searches with no performance impact

**We will** record recent searches in a Rails `after_action` callback in `ResultsController`, the search response is sent to the candidate before the database write occurs.

**Alternatives considered:**

| Alternative | Why rejected |
|---|---|
| Background job for every search | Overhead of serialising params and enqueuing a job for a single lightweight DB write |
| Inline in the controller action | Adds latency to every search request |
| JavaScript/client-side tracking | Doesn't work without JS; inconsistent with server-rendered architecture; can't deduplicate reliably |

**Consequences:**
- Recording a search adds ~1-2ms after the response is sent.
- If the write fails, Sentry captures the exception but the candidate's search is unaffected.

---

## Technical Risks and Mitigations

| Risk | Mitigation |
|---|---|
| **Email alert matching at scale** — running `Courses::Query` per alert could be slow with many alerts | Scope base query to only newly published courses (small set); monitor job duration; if needed, batch alerts by similar filter signatures |
| **JSONB schema drift** — stored attributes may become stale as filters evolve | Validator enforces permitted keys on write; old records without new keys work correctly (no filter = no restriction); consider a migration to backfill if a filter's semantics change |
| **Email delivery limits** — GOV.UK Notify has rate limits | Per-alert jobs allow Sidekiq's built-in rate limiting and retry; stagger delivery across the week if needed |
| **Undo race condition** — candidate clears searches, cleanup job runs before undo | Cleanup only deletes discarded records older than 1 day; undo window is effectively the session duration |
| **Unique index on array column** — PostgreSQL array comparison in unique indexes requires exact match including order | Service sorts subjects array before storage, ensuring consistent ordering |

---

## Implementation Plan

| Phase | Scope | Flag |
|---|---|---|
| **Phase 1** | `recent_searches` migration, model, validator, `RecordRecentSearchService`, `ResultsController` integration | `:candidate_accounts` |
| **Phase 2** | `RecentSearchesController`, ViewComponents, navigation, clear/undo flow | `:candidate_accounts` |
| **Phase 3** | `CleanupRecentSearchesJob`, sidekiq-cron schedule | `:candidate_accounts` |
| **Phase 4** | `email_alerts` migration, model, `CreateEmailAlertService` | `:email_alerts` |
| **Phase 5** | `EmailAlertsController`, create/unsubscribe flows, ViewComponents | `:email_alerts` |
| **Phase 6** | `MatchCoursesToEmailAlertsService`, `EmailAlertMailer`, weekly job | `:email_alerts` |
| **Phase 7** | Analytics events, monitoring, alerting | Both |

Each phase is independently deployable and testable. Feature flags ensure no user-facing changes until the team is ready.

---

## References

- Product spec: `architecture.md` in this repository
- Existing patterns: `SavedCourse` model, `Find::SaveCourseService`, `Courses::Query`
- Discard gem: https://github.com/jhawthorn/discard
- Rails SignedId: https://api.rubyonrails.org/classes/ActiveRecord/SignedId.html
- GOV.UK Notify: https://www.notifications.service.gov.uk/
