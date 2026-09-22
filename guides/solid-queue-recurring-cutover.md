# Solid Queue recurring cutover

PTT keeps Sidekiq Cron (`Settings.bg_jobs`) as the live scheduler until the
global Active Job adapter cutover. `config/recurring.yml` is the Solid Queue
replacement; the `solid-queue-worker` pod starts with
`SOLID_QUEUE_SKIP_RECURRING=true` so both systems cannot enqueue the same
schedule at once.

## Cutover (run once, atomically)

1. Confirm every queue in `config/queue.yml` is consumed, including
   `solid_queue_recurring`, `mailers`, and `low_priority`.
2. In a production Rails console (or equivalent Sidekiq Cron admin path),
   destroy every Sidekiq Cron entry that matches `Settings.bg_jobs` keys for
   that environment. Do not leave cron polling enabled with empty jobs if the
   initializer would reload them on the next Sidekiq boot — disable cron load
   or remove `bg_jobs` as part of the same release that enables Solid Queue
   recurrence.
3. Remove `SOLID_QUEUE_SKIP_RECURRING=true` from the `solid-queue-worker`
   Terraform command (or set it to `false`) and apply so the scheduler boots.
4. Verify Mission Control / `solid_queue_recurring_tasks` shows exactly one
   source for each expected task, and that the next run times are UK-local.
5. Confirm Sidekiq Cron no longer enqueues the same classes.

## Rollback

1. Set `SOLID_QUEUE_SKIP_RECURRING=true` on the Solid Queue worker and roll out
   so the scheduler stops first.
2. Restore Sidekiq Cron (`Settings.bg_jobs` load) and scale Sidekiq workers as
   needed.
3. Reconcile any jobs already accepted by Solid Queue before replaying them —
   do not double-send weekly email alerts or GIAS imports.

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
