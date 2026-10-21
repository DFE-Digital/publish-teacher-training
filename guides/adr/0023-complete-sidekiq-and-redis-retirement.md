# 23. Complete the Sidekiq and Redis retirement

Date: 21 October 2026

## Status

Proposed

This draft describes the completed retirement. Accept it once the teardown has
been verified in every environment; the wording below is not deployment evidence.

## Context

[ADR 22][adr-22] records the application
architecture, retry behaviour and recovery boundary after moving to Solid Queue,
Solid Cache and Postgres. This decision completes that work by retiring the
remaining Redis infrastructure and records how the changes fitted together.

Previously, Publish and Find used two Redis instances per environment. Cache
Redis served `Rails.cache`. Worker Redis held Sidekiq jobs and schedules,
feature flags, cycle settings and some multi-step form drafts. Moving one of
these responsibilities did not make the others safe to remove.

Azure Cache for Redis retirement prompted the change. We chose the Rails Solid
components on our existing Postgres database, following
[Apply's migration](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/adr/0027-removing-redis-and-sidekiq-dependencies.md).
Microsoft's current retirement date for the Basic, Standard and Premium tiers
is [30 September 2028](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/retirement-faq).
Apply's earlier October 2026 wording is historical context rather than the
current Standard-tier deadline.

Apply also showed why this needed more than an adapter change: its
[mail and analytics queues needed matching consumers](https://github.com/DFE-Digital/apply-for-teacher-training/pull/12118),
[worker capacity needed adjustment](https://github.com/DFE-Digital/apply-for-teacher-training/pull/12126)
and [job arguments needed additional log filtering](https://github.com/DFE-Digital/apply-for-teacher-training/pull/12134).
Publish added queue-routing checks and explicit retry policies, and moved its
schedules to `config/recurring.yml`. Apply retained Clockwork.

## Options

### 1. Retain the unused Redis infrastructure

This avoids an immediate destructive infrastructure change, but keeps its cost,
patching, alerts and credentials to manage. Once application mirroring stops,
Redis contains stale state and cannot support redeploying a Redis-reading release.

### 2. Remove Redis after verifying application independence

This removes the unused services and their operational overhead. It requires
evidence that the application no longer uses Redis and an explicit disposition
for the old jobs and state. Destruction permanently removes the remaining Redis
data.

## Decision

We completed the migration in stages, then removed the remaining Redis
infrastructure. Solid Queue, Solid Cache, feature flags and cycle settings now
use the primary Postgres database. ADR 22 remains the reference for the runtime
architecture and retry decisions.

### Migration sequence

1. **Move the cache.** [#6372](https://github.com/DFE-Digital/publish-teacher-training/pull/6372)
   introduced Solid Cache and protections for analytics and sanitised dumps.
   [#6435](https://github.com/DFE-Digital/publish-teacher-training/pull/6435)
   made its disposable entries `UNLOGGED` to reduce WAL pressure, then
   [#6400](https://github.com/DFE-Digital/publish-teacher-training/pull/6400)
   switched `Rails.cache`. Worker Redis remained in use.
2. **Move background jobs.** [#6450](https://github.com/DFE-Digital/publish-teacher-training/pull/6450)
   added the queue schema and
   [#6453](https://github.com/DFE-Digital/publish-teacher-training/pull/6453)
   deployed a worker and Mission Control alongside Sidekiq.
   [Explicit retries](https://github.com/DFE-Digital/publish-teacher-training/pull/6457)
   and a [two-job pilot](https://github.com/DFE-Digital/publish-teacher-training/pull/6485)
   preceded the migration of
   [scheduled jobs and bulk updates](https://github.com/DFE-Digital/publish-teacher-training/pull/6532),
   [email alerts](https://github.com/DFE-Digital/publish-teacher-training/pull/6533)
   and [rollover and backfill](https://github.com/DFE-Digital/publish-teacher-training/pull/6534).
   [#6574](https://github.com/DFE-Digital/publish-teacher-training/pull/6574)
   switched the global adapter and recurring scheduler, including framework
   mailers, analytics and cache expiry. Sidekiq remained available to drain
   existing work before [#6575](https://github.com/DFE-Digital/publish-teacher-training/pull/6575)
   scaled its workers to zero. Changing adapters did not transfer queued payloads.
3. **Move application state.** [#6581](https://github.com/DFE-Digital/publish-teacher-training/pull/6581)
   moved flags and cycle settings into `feature_flag_state` and `site_setting`.
   These are application state, so they belong in relational tables. Form drafts
   moved to Solid Cache with a 24-hour logical expiry; existing Redis drafts were
   not copied. A temporary Redis mirror kept older releases usable during this
   stage.
4. **Remove the application dependency.** [#6610](https://github.com/DFE-Digital/publish-teacher-training/pull/6610)
   removed Sidekiq and Redis runtime code, mirroring, boot reconciliation and
   Redis URL injection. The legacy sync columns were retained for older pods
   during the rolling deployment. Redis instances remained temporarily so their
   activity could be checked after all old pods had stopped.
5. **Remove the infrastructure.** We removed the `redis_worker` and `redis_cache`
   module calls from `terraform/aks/databases.tf`: eight Azure Cache for Redis
   Standard C1 instances across production, sandbox, QA and staging, their
   private endpoints and memory alerts, and the Redis deployments and services
   used by review apps and other non-Azure environments. Endpoint-owned network
   and DNS configuration was removed with them. Shared DNS zones, subnets and
   unrelated networking remain. Application pods no longer receive Redis URLs.

### Retirement gate

Retirement requires an agreed Redis-free soak, including daily and weekly jobs,
with no application connections, reads or writes. Metrics and connection
attribution are used together because Azure internal activity can remain.
Flags and cycle settings must be verified in Postgres, and every old Sidekiq
queue, retry set, scheduled set, dead job and cron entry needs a recorded outcome.

The teardown change owns the environment-specific plans, approvals and completion
record. Plans must remove only Redis-owned resources, with no replacement of
Postgres, web, Solid Queue or unrelated networking. The rollout order is lower
environments, then sandbox, then production in the agreed change window, with
the normal production database backup taken first.

Completion evidence includes the remaining resource inventory, absence of
PTT-owned Redis workloads and Redis URL configuration, and checks of health,
mail, analytics, delayed and recurring jobs, cache expiry and key user journeys.
It also records Postgres and Solid Queue behaviour and the measured cost saving.
Sensitive plans, queue arguments and Redis values do not belong in this public
repository.

## Consequences

### Recovery changed before infrastructure deletion

Early stages allowed a cache-store change or a job-routing change to be reverted
while the old runtime remained available. Job recovery still needed queue and
scheduler reconciliation to avoid losing or repeating work. The temporary
state mirror in #6581 supported its documented older-release rollback.

That option ended when #6610 stopped mirroring. Keeping Redis running, or keeping
the legacy sync columns, did not make an older Redis-reading release safe.
Infrastructure destruction then removed the remaining Redis data permanently.
Recreating the instances would not recover it. A Postgres backup does not restore
Redis data or undo external effects such as sent emails. Recovery follows
[ADR 22][adr-22]: a forward fix or a release
deliberately compatible with the current Postgres state.

### Operations and data protection follow the new stores

We have fewer backing services to operate, with jobs and cache sharing database
capacity with the application. Queue tables remain logged; Solid Cache's
`UNLOGGED` entries are disposable, including form drafts. Monitor database
connections, CPU, locks and WAL alongside queue age, failures and worker restarts.

Job arguments, errors and cached drafts can contain personal data. Their tables
remain analytics-blocklisted and excluded from selected Airbyte streams; queue
and cache contents are wiped from sanitised dumps. Log and Mission Control
filtering still need care when adding new argument shapes. A draft's 24-hour
logical expiry does not guarantee physical deletion at that time: unread rows
can remain until Solid Cache's global cleanup.

For day-to-day operations:

- Use Mission Control at `/jobs` on the Publish host with system-admin access.
  Check side effects before manually retrying failed jobs; the
  [email-alert follow-up](https://github.com/DFE-Digital/publish-teacher-training/pull/6576)
  explains the delivery and catch-up behaviour.
- Use the [healthcheck guide](../healthchecks.md) to distinguish `/ping` from
  database and Solid Queue heartbeat checks. Scheduler checks depend on the
  environment's recurring configuration. Healthy processes alone do not prove
  that jobs are completing.
- Use [the cutover and verification guide](../solid-queue-recurring-cutover.md),
  [recurring schedules](../../config/recurring.yml) and
  [queue configuration](../../config/queue.yml). Schedules use Europe/London;
  review and sandbox intentionally have no recurring tasks.
- Keep the [worker coordination around database restores](https://github.com/DFE-Digital/publish-teacher-training/pull/6510)
  and preserve each environment's flags and cycle settings. Legacy sync-column
  cleanup follows the staged compatibility rules in ADR 22.

## Related decisions

- [ADR 22: Solid Queue on the primary database and Redis independence][adr-22]
- [Apply ADR 27: removing Redis and Sidekiq dependencies](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/adr/0027-removing-redis-and-sidekiq-dependencies.md)
- [Apply's full cache cutover](https://github.com/DFE-Digital/apply-for-teacher-training/pull/11952)
- [Apply's application and infrastructure retirement](https://github.com/DFE-Digital/apply-for-teacher-training/pull/12168)

[adr-22]: https://github.com/DFE-Digital/publish-teacher-training/blob/1233ba529b91353e8564c5581dc56160542710cd/guides/adr/0022-solid-queue-and-redis-independence.md
