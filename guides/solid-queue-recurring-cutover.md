# Solid Queue cutover

Solid Queue is the Active Job adapter (`config.active_job.queue_adapter`) and
`config/recurring.yml` is the only schedule source. Sidekiq and Redis stay
deployed so legacy Sidekiq payloads can drain and so the cutover can be rolled
back.

## How the cutover happens

The release that switched the adapter does it per environment as it deploys:

1. Every job enqueued by the new web and worker pods goes to Solid Queue.
2. The `solid-queue-worker` starts without `SOLID_QUEUE_SKIP_RECURRING`, so its
   scheduler loads `config/recurring.yml`. Each replica runs a scheduler; the
   unique `(task_key, run_at)` index on `solid_queue_recurring_executions`
   enqueues each run once.
3. When the Sidekiq pods boot on the new release they run
   `Sidekiq::Cron::Job.destroy_all!` (`config/initializers/sidekiq.rb`). Sidekiq
   Cron entries persist in Redis, so this is what stops the old schedules.
4. Sidekiq keeps working through whatever was already in its queues, retry set
   and scheduled set.

Deploy on a weekday daytime, Monday to Wednesday, so no schedule (00:00 to
03:00 UK time) falls inside the deploy and a Friday 03:00 weekly alert run
lands inside the soak. Avoid rollover and Find opening.

## Checks after each environment deploys

In a Rails console:

```ruby
Sidekiq::Cron::Job.all.size # => 0
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

## Draining Sidekiq

Watch the Sidekiq queues, retry set and scheduled set reach zero.
`BulkUpdateCourseSchoolsJob` reschedules failed courses five minutes later, so
wait for those scheduled entries to clear. Deal with the dead set one job at a
time: re-enqueue on Solid Queue only after checking the job is safe to run
again, otherwise delete it. Record each decision.

Never run `FLUSHDB` or delete keys by pattern: feature flags, site settings and
form state share the worker Redis.

Scale the Sidekiq workers to zero only once the drain is signed off.

## Rollback

1. Set `SOLID_QUEUE_SKIP_RECURRING: true` in
   `terraform/aks/workspace_variables/app_config.yml` and apply, so the Solid
   Queue scheduler stops first. `/healthcheck` stops expecting a scheduler.
2. Revert the cutover release. That restores the Sidekiq adapter, the
   `bg_jobs` settings and the Sidekiq Cron loader, which reloads the schedules
   when Sidekiq boots.
3. Scale the Sidekiq workers back up if they were scaled down.
4. Check Solid Queue's ready and scheduled jobs before letting anything replay,
   so nothing runs twice. Weekly email alerts and the GIAS import matter most.

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
