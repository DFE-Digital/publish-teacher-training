# Solid Queue job migration (card 7)

PTT-owned jobs move to Solid Queue one tranche at a time with a per-class
`self.queue_adapter = :solid_queue`. The global adapter stays `:sidekiq` until
card 8, so Sidekiq keeps running Action Mailer (`deliver_later`), DfE Analytics,
Solid Cache expiry and anything already in its queues.

Sidekiq Cron is still the only scheduler (`SOLID_QUEUE_SKIP_RECURRING=true`).
It enqueues Active Job classes with `perform_later`, so a cron-triggered job
runs wherever its class adapter points. See
[solid-queue-recurring-cutover.md](solid-queue-recurring-cutover.md) for moving
the schedules themselves.

`spec/jobs/solid_queue_routing_spec.rb` lists the jobs still on Sidekiq and
fails if a job is neither on Solid Queue nor listed there.

## Jobs

Solid Queue has no Sidekiq-style automatic retries. Under the Sidekiq adapter
every Active Job without `without_auto_retry` got Sidekiq's 25 retries; each job
below now declares its own behaviour.

| Tranche | Job | Queue | Retries | Safe to run twice? |
| --- | --- | --- | --- | --- |
| pilot | `GeocodeJob` | `geocoding` | network errors, 5 attempts | yes, overwrites lat/lon |
| pilot | `UpdateCourseSchoolsJob` | `default` | none (`without_auto_retry`) | yes, sets the school list |
| 1 | `SaveStatisticJob` | `save_statistic` | `retry_on_failure` (3) | one row per run |
| 1 | `CleanupRecentSearchesJob` | `default` | `retry_on_failure` (3) | yes, `delete_all` |
| 1 | `CleanupSchoolBulkUpdateDraftsJob` | `default` | `retry_on_failure` (3) | yes, `delete_all` |
| 1 | `GiasImportJob` | `default` | `Gias::DownloadError`, 3 attempts, 30 min apart | yes, upserts by URN |
| 1 | `SlackNotificationJob` | `default` | `retry_on_failure` (3) | duplicate message is harmless |
| 1 | `BulkUpdateCourseSchoolsJob` | `low_priority` | `retry_on_failure` (3), plus its own retry of failed courses | yes, same diff lands on same schools |
| 2 | `SendWeeklyEmailAlertsJob` | `default` | none (`without_auto_retry`) | no, fans out emails |
| 2 | `EmailAlertMailerJob` | `mailers` | Notify server errors and timeouts, 3 attempts | guarded by `last_sent_at` |
| 3 | `RolloverJob` | `default` | none (`without_auto_retry`) | no, starts a new rollover |
| 3 | `RolloverProvidersBatchJob` | `low_priority` | none | provider jobs skip rolled providers |
| 3 | `RolloverProviderJob` | `low_priority` | none | yes, skips providers already in target cycle |
| 3 | `RolloverMonitoringJob` | `default` | none | yes, returns once finished |
| 3 | `BlankCoordinatesBackfill::BackfillJob` | `default` | none | no, starts a new backfill |
| 3 | `BlankCoordinatesBackfill::BatchJob` | `low_priority` | none | yes, overwrites lat/lon |
| 3 | `BlankCoordinatesBackfill::MonitoringJob` | `default` | none | yes, returns once finished |

Bulk work (rollover fan-out, backfill batches, bulk school updates) sits on
`low_priority`, which has its own worker in production, so it cannot hold up
`default`, `geocoding` or `mailers`.

## Checking a tranche

Mission Control is at `/jobs` for admins. Blazer can run the same checks.

```sql
-- Throughput and failures per job since the deploy
SELECT class_name, queue_name, count(*) AS total, count(finished_at) AS finished,
       min(created_at) AS first_seen, max(created_at) AS last_seen
FROM solid_queue_jobs
GROUP BY 1, 2
ORDER BY 1;

SELECT j.class_name, f.created_at, left(f.error, 300) AS error
FROM solid_queue_failed_executions f
JOIN solid_queue_jobs j ON j.id = f.job_id
ORDER BY f.created_at DESC
LIMIT 50;

-- Delayed work should leave scheduled executions once it is due
SELECT j.class_name, s.scheduled_at
FROM solid_queue_scheduled_executions s
JOIN solid_queue_jobs j ON j.id = s.job_id
WHERE s.scheduled_at < now() - interval '1 minute'
ORDER BY s.scheduled_at;

-- Latency: time from due to finished, per queue, last 24 hours
SELECT queue_name,
       percentile_cont(0.5) WITHIN GROUP (ORDER BY finished_at - coalesce(scheduled_at, created_at)) AS p50,
       percentile_cont(0.95) WITHIN GROUP (ORDER BY finished_at - coalesce(scheduled_at, created_at)) AS p95
FROM solid_queue_jobs
WHERE finished_at > now() - interval '1 day'
GROUP BY 1;

-- Table growth (finished-job cleanup is off until the recurring cutover)
SELECT relname, pg_size_pretty(pg_total_relation_size(relid)) AS size, n_live_tup
FROM pg_stat_user_tables
WHERE relname LIKE 'solid_queue_%'
ORDER BY pg_total_relation_size(relid) DESC;
```

## Gates

Take a Sidekiq baseline before tranche 1 and compare after each tranche. Hold the
next tranche if any gate regresses.

- Enqueue-to-finish latency per queue (p50/p95 above) against Sidekiq's
- Failed executions: none unexplained
- Due scheduled executions: none older than a minute
- Database CPU, IOPS, lock waits and WAL rate against the baseline
- `solid_queue_*` table size growing in line with job volume
- Airbyte sync lag unchanged (`solid_queue_*` tables are excluded from analytics)

## Proving delayed and fan-out work

- **Dispatcher**: `TestJob::DispatcherCanaryJob.set(wait_until: 1.minute.from_now).perform_later`
  should finish about a minute later.
- **Weekly email alerts** (tranche 2): in QA, `SendWeeklyEmailAlertsJob.perform_later`
  schedules `EmailAlertMailerJob`s across the next hour. They should leave
  `solid_queue_scheduled_executions` at their `scheduled_at` and finish on `mailers`.
- **Rollover** (tranche 3): run the full rollover in the `rollover` environment.
  Record when it started, when the last provider finished and how many
  monitoring attempts it used. If the last provider finishes after monitoring
  gives up (stagger plus 5 checks of 5 minutes), raise
  `LOW_PRIORITY_QUEUE_THREADS` or `LOW_PRIORITY_QUEUE_PROCESSES` on the
  solid-queue-worker, keeping threads within `DATABASE_CONNECTION_POOL_SIZE`.
- **Blank coordinate backfill** (tranche 3): in QA,
  `BlankCoordinatesBackfill::BackfillJob.perform_later(year, dry_run: true)`,
  then a real run on a small cycle.

## Rollback

Remove `self.queue_adapter = :solid_queue` from the job and deploy. Sidekiq
still consumes every queue, so new enqueues go back to it straight away. Jobs
already accepted by Solid Queue keep running there; check Mission Control before
replaying anything so emails and imports are not sent twice.
