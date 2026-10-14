# Application state off Redis

Feature flags and the Find cycle switcher settings (`cycle_schedule`,
`deadline_banner`) live in the `feature_flag_state` and `site_setting` tables.
Every change is also written to the worker Redis in the old format, so a
release that still reads Redis can be redeployed. Requests only read the
database: one query loads every flag, another every setting, and both are
memoised on `Current` for the request.

Form stores (`Stores::BaseStore`) write to Solid Cache under `form_stores/`
keys that expire after 24 hours. Drafts left in Redis are not copied over, so
anyone part way through one of those forms during the deploy starts that step
again.

## Deploying

The data migration copies the flags and settings from Redis when the first web
pod boots. Do not change flags or the cycle schedule while the deploy is
rolling: an old pod would write only to Redis.

After each environment deploys, in a Rails console:

```ruby
FeatureFlagState.pluck(:name, :active) # matches the support feature flags page before the deploy
SiteSetting.pluck(:name, :value)       # empty means the real schedule
```

Check the support feature flags page shows the same states and last-updated
times as before.

## Checking Redis is no longer used by requests

```sh
bundle exec rake legacy_redis_state:audit
```

It prints key counts by prefix and the total GET and SET calls, never values.
Run it twice a few minutes apart under normal traffic. GET calls should stay
flat apart from Sidekiq, and `Stores::*` keys should only fall as they are
removed. SET calls only rise when someone changes a flag or the cycle.

## Rolling back

1. Copy the database values to Redis, so the older release sees the current
   flags and cycle:

   ```sh
   bundle exec rake legacy_redis_state:sync_to_redis
   ```

2. Redeploy the older release.

Form drafts saved since the deploy are lost on rollback.

## Rolling forward again

The data migration has already run, so it will not copy changes made on the
older release. Straight after the deploy, copy Redis back to the database:

```sh
bundle exec rake legacy_redis_state:backfill_database
```

Never run `FLUSHDB` or delete keys by pattern while the older release is still
an option.
