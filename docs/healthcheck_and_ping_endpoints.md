# Healthcheck and Ping Endpoints

Healthchecks are handled by [`HeartbeatController`](../app/controllers/heartbeat_controller.rb).

## Ping

Use the `/ping` endpoint as a lightweight check to see if the app is up. This
can be used by load-balancers, for example, which may frequently test whether to
send traffic to a given host running this app. The response will simply be
`PONG`, with a 200 status code, and not specific resources are checked when this
endpoint is activated.

## Healthcheck

Use the `/healchtheck` to check whether that the app's dependencies are working.
This returns a JSON structure that lists the checks it performs and their
results. For example:

```json
{
  "checks": {
    "database": true,
    "redis": true,
    "sidekiq_processes": true
  }
}
```

The available checks:

### `database`

Check that 'ActiveRecord' connection to the database is active.

### `redis`

Checks that Sidekiq can connect to the Redis server.

### `sidekiq_processes`

Check which queues currently have jobs, as reported by Sidekiq, and checks that
there is a Sidekiq running for each one. In theory there should be a process for
each queue that is being used, and we determine which queues are being used by
looking at what jobs we have queued up.

#### Failures caused by stale jobs

This check will fail if there are stale jobs in a queue that doesn't have a
processor running. You can check which queues have jobs by starting the Rails
console (you'll have to use `mcb` if you can't connect to the console, for
example for Azure webapp services) and running:

```ruby
stats = Sidekiq::Stats.new
processes = Sidekiq::ProcessSet.new
stats.queues.keys.each do |queue|
  running = processes.any? { |process| queue.in? process["queues"] }
  puts "#{queue} running? #{running}"
end
```

If you see jobs in a queue that shouldn't be running anymore (e.g. we've retired
`find_sync` and shouldn't see any jobs for it) then you'll need to remove any
job queues that exist for it for this test to return `true`. If, on the other
hand, you only have the queues you expected listed, but no process is listed for
them, then you have a problem.
