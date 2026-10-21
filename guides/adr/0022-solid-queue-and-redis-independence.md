# 22. Solid Queue on the primary database and Redis independence

Date: 20 October 2026

## Status

Accepted

## Context

Publish and Find historically used Sidekiq and Azure Cache for Redis for
background jobs, caching, feature flags, Find cycle switcher settings, and some
multi-step form drafts. Azure is retiring Azure Cache for Redis. Rails now
ships Solid Queue and Solid Cache.

By the time of this ADR:

- Solid Cache holds form drafts and other cache entries on Postgres
- Solid Queue runs every Active Job, with schedules in `config/recurring.yml`
- Feature flags and cycle settings live in Postgres (`feature_flag_state`,
  `site_setting`)
- Sidekiq worker replicas were already scaled to zero

A temporary Redis mirror remained so a release that still *read* flags and
cycle settings from Redis could be redeployed. That rollback window is closed
when the app no longer writes or reconciles Redis.

## Decision

1. **Solid Queue runs on the primary Postgres database**, alongside the
   application schema and Solid Cache. Capacity was sized during the Solid
   Queue cutover. Mission Control at `/jobs` (system admins) is the operator UI.

2. **Retries** use Active Job helpers on `ApplicationJob`:
   - default: `retry_on ActiveRecord::Deadlocked`, discard deserialization errors
   - `without_auto_retry` for jobs that must not auto-retry `StandardError`
   - `fail_without_retry_on` to override an earlier retry and surface the error
     to Solid Queue
   - `retry_on_failure` for a small number of backoff retries before failed
     executions

3. **The app is independent of Redis.** Sidekiq gems, Redis client code, the
   legacy Redis mirror, Sidekiq Web, and the Sidekiq worker deployment are
   removed. `/healthcheck` checks the database and Solid Queue process
   heartbeats only.

4. **Redis retention and rollback boundary.** Redis instances and `REDIS_*`
   URL injection are retained temporarily to verify zero application usage
   before deletion. Check for unexpected application connections, reads and
   writes, then remove the infrastructure in a follow-up change.

   Retaining Redis does not provide a rollback path. Once the app stops
   mirroring changes, Redis state becomes stale. Redeploying a release that
   reads or reconciles feature flags or cycle settings from Redis is not
   supported: it can use stale values or overwrite newer Postgres state.
   Recovery requires a forward fix or a deliberately prepared release
   compatible with the current Postgres state.

5. **Column removal is staged across releases.** Keep `legacy_redis_synced_at`
   on `feature_flag_state` and `site_setting` while older pods still use it
   during rolling deployment. The new models ignore the columns, and they
   remain on the analytics blocklist. Drop them in a later release, once all
   environments run this code and no supported rollback needs them. Keeping
   the columns does not make a release that reconciles from Redis safe to
   redeploy: that reconciliation can overwrite newer Postgres state.

## Consequences

- Ops use Mission Control and Solid Queue tables, not Sidekiq Web or Redis keys
- Nightly database restores continue to preserve each environment's feature
  flags and site settings
- A later change deletes `redis_worker`, `redis_cache`, endpoints, alerts, and
  URL injection once verification confirms zero application usage
