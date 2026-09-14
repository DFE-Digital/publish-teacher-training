# Publish pod memory spikes (September 2026)

Investigated 2026-09-14. Pods idle at ~550 MiB; single pods jumped to ~2.2 GiB
a couple of times a day, then stepped down over 20–30 minutes.

## Cause

`GET https://find-teacher-training-courses.service.gov.uk/sitemap.xml`.

The controller loaded every findable course in the cycle (~11,800) as records,
with all enrichment versions, schools, subjects and providers eager-loaded, to
print three columns. Per request: ~24M allocations, ~25 s, and the serving pod
went from ~600 MiB to ~2.2 GiB. Ruby never gives that heap back, so the pod
sat high until it was rolled. Crawlers and scanners fetch the sitemap several
times a day (five fetches seen on 2026-09-14 alone), which is the "one pod,
~12 h apart" pattern in Grafana.

Fixed by plucking the three columns (`Find::SitemapsController`):
23.4M allocations / 13.7 s → 237k / 0.29 s on production-sized data.

## Evidence

- Pod request logs (`kubectl logs`, `payload.allocations`), 12 pods, one day:
  sitemap 24.6M allocations; next heaviest endpoint 4.5M median
  (`Publish::Courses::SchoolsController#edit`, large providers); everything
  else < 1M.
- Controlled fetch: `kubectl top` on the serving pod 721 MiB → 2231 MiB.
- Two crawler fetches at 14:13 and 14:14 took two other pods 592 MiB → 2218 MiB,
  then 2218 → 1338 MiB over 20 minutes — the Grafana shape.
- While the sitemap rendered, other requests on that pod took 10–14 s.

Not the cause: Sidekiq/cron jobs (they run on `publish-production-worker`),
OOM kills (none), a leak (other pods stay flat between deploys).

## Why one request costs 1.5 GiB

Puma runs one process with 50 threads (`RAILS_MAX_THREADS: 50` in
`terraform/aks/workspace_variables/app_config.yml`) on a 1-CPU pod. Any request
that allocates heavily does so in a process whose heap only grows, and 50
concurrent requests multiply the worst case.

## Sizing

Today: 12 pods × 4Gi (request = limit) = 48 GiB reserved for ~7 GiB in use.
Once the sitemap fix is deployed and the worst-case request is bounded, a
1.5–2Gi limit is realistic, which fits 24+ pods in the same footprint.

## Follow-ups

Tracked as GitHub issues: Puma thread count and request timeouts; lower the
memory limit / raise replicas; public API eager-loads every enrichment version;
course schools page for large providers; synchronous CSV exports; Blazer on
the primary DB with no row cap; `GiasImportJob` loads the whole GIAS CSV.

## Reproducing this kind of investigation

- `kubectl top pods -n bat-production -l app=publish-production` every 30 s
  finds the pod; `kubectl logs` on that pod, filtered with
  `jq -R 'fromjson? | select(.payload.allocations > 1000000)'`, names the
  request. `payload.allocations` is process-wide, so use medians per endpoint.
- Logit has the same log lines (index `logstash-*`): filter on `host` (pod name)
  and time window, sort by `payload.allocations`.
