# Solid Queue cutover

Solid Queue is the Active Job adapter (`config.active_job.queue_adapter`) and
`config/recurring.yml` is the only schedule source. Sidekiq has been removed from
the application; see
[ADR 22](adr/0022-solid-queue-and-redis-independence.md).

Redis infrastructure is retained temporarily to verify zero application usage
before deletion. Retaining Redis does not provide a rollback path: its state
becomes stale once mirroring stops. See ADR 22 for the recovery boundary.

## How the cutover happened

The release that switched the adapter did it per environment as it deployed:

1. Every job enqueued by the new web and worker pods went to Solid Queue.
2. The `solid-queue-worker` started without `SOLID_QUEUE_SKIP_RECURRING`, so its
   scheduler loaded `config/recurring.yml`. Each replica runs a scheduler; the
   unique `(task_key, run_at)` index on `solid_queue_recurring_executions`
   enqueues each run once.
3. Sidekiq Cron entries were cleared while Sidekiq was still bootable, then
   Sidekiq workers were scaled to zero and later removed from the app.

## Checks after each environment deploys

In a Rails console:

```ruby
SolidQueue::RecurringTask.pluck(:key) # matches the table below for this environment
SolidQueue::Process.group(:kind).maximum(:last_heartbeat_at) # Worker, Dispatcher and Scheduler all recent
```

- `/healthcheck` reports `solid_queue_processes: true`.
- Mail: trigger a magic link (QA) and check the `mailers` job finishes and the
  email arrives.
- Analytics: request events reach BigQuery, and the 00:30 entity table check
  runs (production).
- Cache: `SolidCache::ExpiryJob` executions appear on `low_priority`.
- Dispatcher: `TestJob::DispatcherCanaryJob.set(wait_until: 1.minute.from_now).perform_later`
  moves from scheduled to finished.
- Monitor oldest ready job age per queue, failed executions, worker memory and
  restarts, Postgres CPU, connections, locks and WAL, and Airbyte lag.

## Environment parity

| Task | Production | QA | Staging | Review / sandbox / loadtest |
| --- | --- | --- | --- | --- |
| `SaveStatisticJob` | 00:00 | 00:00 | 00:00 | — |
| `DfE::Analytics::EntityTableCheckJob` | 00:30 | — | — | — |
| `GiasImportJob` | 02:30 | — | — | — |
| `CleanupRecentSearchesJob` | 03:00 | 03:00 | — | — |
| `CleanupSchoolBulkUpdateDraftsJob` | 03:00 | 03:00 | — | — |
| `SendWeeklyEmailAlertsJob` | Fri 03:00 | — | — | — |
| Finished job / batch cleanup | hourly :12 | hourly :12 | hourly :12 | — |

All cron expressions in `config/recurring.yml` use `Europe/London`.
