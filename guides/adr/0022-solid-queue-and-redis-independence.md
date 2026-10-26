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

4. **Redis infrastructure is removed.** The `redis_worker` and `redis_cache`
   modules, their private endpoints, memory alerts, and review-app Redis
   deployments are deleted. `REDIS_*` URLs are not injected. Destroyed Redis
   data cannot be recovered, and it was already stale: the app no longer
   mirrors flags or cycle settings. Redeploying a release that reads or
   reconciles those values from Redis is not supported. Recovery requires a
   forward fix or a deliberately prepared release compatible with the current
   Postgres state.

5. **`legacy_redis_synced_at` is dropped in this release.** Models keep the
   column in `ignored_columns` until the migration has run in every
   environment. A follow-up then removes those lines. Keeping the columns
   ignored does not make a release that reconciles from Redis safe to
   redeploy: that reconciliation can overwrite newer Postgres state.

## Consequences

- Ops use Mission Control and Solid Queue tables, not Sidekiq Web or Redis keys
- Nightly database restores continue to preserve each environment's feature
  flags and site settings
- Applying this change deletes the Redis caches, endpoints and alerts. Do that
  only after the Redis-free soak is signed off
