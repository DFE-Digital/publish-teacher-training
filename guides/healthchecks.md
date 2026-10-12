# Healthcheck and Ping Endpoints

Healthchecks are handled by [`HeartbeatController`](../app/controllers/heartbeat_controller.rb).

## Ping

Use the `/ping` endpoint as a lightweight check to see if the app is up. This
can be used by load-balancers, for example, which may frequently test whether to
send traffic to a given host running this app. The response will simply be
`PONG`, with a 200 status code, and not specific resources are checked when this
endpoint is activated.

## Healthcheck

Use the `/healthcheck` to check whether that the app's dependencies are working.
This returns a JSON structure that lists the checks it performs and their
results. For example:

```json
{
  "checks": {
    "database": true,
    "redis": true,
    "solid_queue_processes": true
  }
}
```

The available checks:

### `database`

Check that 'ActiveRecord' connection to the database is active.

### `redis`

Checks that the app can connect to the worker Redis server. Feature flags, site
settings and some form state still live there.

### `solid_queue_processes`

Checks that the `solid-queue-worker` has a Solid Queue worker and dispatcher with
a heartbeat inside `SolidQueue.process_alive_threshold` (5 minutes). In
environments with tasks in `config/recurring.yml`, it also needs a live
scheduler, unless `SOLID_QUEUE_SKIP_RECURRING` is set.

If this check fails, look at the `solid-queue-worker` pods and at the processes
in Mission Control, or run this in a Rails console:

```ruby
SolidQueue::Process.group(:kind).maximum(:last_heartbeat_at)
```
