# Application state off Redis

Feature flags and the Find cycle switcher settings (`cycle_schedule`,
`deadline_banner`) live in the `feature_flag_state` and `site_setting` tables.
After a database change commits, it is also written to the worker Redis in the
old format so a release that still reads Redis can be redeployed. A failed
mirror remains marked as pending. Before a web process starts, it retries
pending database-to-Redis writes and then reconciles Redis into the database.
If Redis is unreachable the boot continues on the database state and reports
the error. If Redis is empty but the database still has rows, the replace is
skipped so a flush cannot wipe flags or cycle settings. These operations use
one database advisory lock so they cannot overwrite a concurrent change.
Requests only read the database: one query loads every flag, another every
setting, and both are memoised on `Current` for the request.

Form stores (`Stores::BaseStore`) write to Solid Cache under `form_stores/`
keys with a 24-hour logical expiry. Unread rows can remain in Postgres until
Solid Cache's global 30-day cleanup runs. Drafts left in Redis are not copied,
so anyone using one of those forms while old and new pods are mixed may need
to repeat the current step. Avoid these forms while the deploy is rolling.

## Deploying

Every web pod copies the flags and settings from Redis after migrations and
before starting the Rails server (`bin/start-web`), so neither the first
deploy nor a roll forward after a rollback serves stale database state. Do not change
flags or the cycle schedule while the deploy is rolling: an old pod would
write only to Redis after a new pod had reconciled.

After each environment deploys, in a Rails console:

```ruby
FeatureFlagState.pluck(:name, :active) # matches the support feature flags page before the deploy
SiteSetting.pluck(:name, :value)       # empty means the real schedule
```

Check the support feature flags page shows the same states and last-updated
times as before.

The database-restore workflow takes the same advisory lock, excludes other
table writers and preserves each environment's feature flags and cycle
settings instead of replacing them with production values.

## Checking Redis is no longer used by requests

```sh
bundle exec rake legacy_redis_state:audit
```

It prints key counts by prefix and the total GET and SET calls, never values.
Run it twice a few minutes apart under normal traffic. GET calls should stay
flat apart from Sidekiq and web process starts. Existing `Stores::*` keys remain
until Redis is removed, but no new request reads or writes them. SET calls only
rise when someone changes a flag or the cycle.

## Rolling back

1. Copy the database values to Redis, and remove known keys that are absent
   from the database, so the older release sees the current flags and cycle:

   ```sh
   bundle exec rake legacy_redis_state:sync_to_redis
   ```

2. Redeploy the older release.

Form drafts saved since the deploy are lost on rollback.

## Rolling forward again

Freeze flag and cycle changes during the deploy. Each new web pod copies Redis
back to the database before accepting traffic, including changes made while
the older release was running. After the deploy, repeat the checks in
[Deploying](#deploying).

Never run `FLUSHDB` or delete keys by pattern while the older release is still
an option.
