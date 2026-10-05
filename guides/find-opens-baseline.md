# Find opens baseline

What production looked like on the day Find opened, as a baseline for planning the next opening, load
tests and scaling. Add a dated section each year rather than editing the last one.

All times are UK time unless marked UTC. Figures are aggregates; nothing here identifies a candidate.

## 2026 (1 October)

Compared with Thursday 24 September 2026, a normal weekday the week before.

### Before you compare

- **The infrastructure changed between the two days.** `751a48417` (25 September) moved the web app from
  12 pods × 4Gi to 36 × 1Gi and Postgres from `GP_Standard_D4ds_v5` to `GP_Standard_D8ds_v5`.
  `4115a5e7e` (30 September) took the web app down to 18 pods. Faster responses on opens day are partly
  bigger infrastructure, not only lighter load.
- **24 September included a k6 load test** in the 09:00 and 16:00 hours: 76,107 requests from
  `Grafana k6/1.2.3` at the edge. Rows marked non-bot leave it out; all-traffic rows include it.
- **62% of opens-day requests were crawlers, monitoring or static assets.** "Non-bot" below means Front Door
  requests excluding user agents matching bot, crawler, spider, k6, curl and similar, empty user agents,
  `/ping`, `/healthcheck` and `/assets/*`. It still includes some scripted traffic, such as the scanner in the
  timeline.

### Environment

| | Opens day |
|---|---|
| Web | 18 pods (`publish-production`), 1Gi memory, 1 CPU limit |
| Workers | 2 Sidekiq (`publish-production-worker`), 1 Solid Queue |
| Puma | 1 process × 50 threads (`RAILS_MAX_THREADS`), database pool 50 |
| Postgres | `s189p01-ptt-pd-pg`, `GP_Standard_D8ds_v5`, high availability, shared by Find, Publish and the API |
| Worker Redis | `s189p01-ptt-production-redis-worker`, Standard C1, patch window Sunday 02:00 UTC |
| Front Door | `s189p01-fttc-svc-domains-fd`, caches `/assets/*` only, WAF in front |

Source: `terraform/aks/workspace_variables/production.tfvars.json`, `terraform/aks/workspace_variables/app_config.yml`,
`kubectl -n bat-production get deployments`, `az redis show`. The old domain's Front Door,
`s189p01-ftt-svc-domains-fd`, only redirects and is not counted here.

### Timeline

| Time | What happened | Source |
|---|---|---|
| 08:23–08:25 | Worker Redis server load reached 57%, then reported no metrics for a minute. Between 08:24:51 and 08:25:06, Find and Publish pages and Sidekiq jobs failed to connect to it. Outside the patch window, cause unconfirmed | Azure Monitor, Sentry, Logit |
| 09:00 | Non-bot traffic starts to rise | Front Door |
| 10:00–11:59 | Busiest non-bot hours: 6,244 and 6,329 requests | Front Door |
| 10:18–14:56 | Six deployments; three between 14:12 and 14:56. No pod restarts | Grafana |
| 17:04:36 | Busiest second of the day, 145 requests: one vulnerability scanner probing for `.env`, `wp-config.php.bak` and `phpinfo.php`. Mostly 404s and redirects | Front Door |
| 18:00–21:59 | 3.6–4.7k non-bot requests an hour, then under 3k from 22:00 | Front Door |

### Traffic

| | Opens | 24 Sep | Source |
|---|---|---|---|
| All requests at the edge | 237,933 | 158,223 | Front Door |
| Non-bot requests | 90,829 | 24,560 | Front Door |
| Busiest non-bot hour | 6,329 (11:00), 1.8 a second | 1,721 (15:00) | Front Door |
| Busiest non-bot minute | 339 (21:25), 5.7 a second | 573 (18:45) | Front Door |
| Busiest minute, all traffic | 928 (06:07, 826 of them ShapBot) | 5,158 (k6) | Front Door |
| Requests a second, 99th percentile second | 14 all, 6 non-bot | — | Front Door |
| Busiest second | 145 (scanner) | — | Front Door |

Non-bot traffic was 3.7 times the week before. Averaged over its busiest hour, Find served under 2 non-bot
requests a second; its busiest minute ran at under 6.

Busiest non-bot pages on opens day (Front Door):

| Path | Requests |
|---|---|
| `/results` | 19,860 |
| `/course/:provider/:course` | 13,677 |
| `/geolocation-suggestions` | 12,224 |
| `/track_click` | 8,681 |
| `/` | 5,500 |
| `/candidate/saved-courses` | 2,437 |
| `/course/:provider/:course/provider/:provider` | 2,034 |
| `/course/:provider/:course/confirm-apply` | 1,931 |

### Performance

Response time per endpoint on opens day, in milliseconds, all traffic including bots (Logit):

| Endpoint | Requests | p50 | p95 | p99 | DB p95 | View p95 | Queries a request |
|---|---|---|---|---|---|---|---|
| `ResultsController#index` | 28,669 | 309 | 595 | 816 | 327 | 308 | 125 |
| `CoursesController#show` | 24,827 | 80 | 201 | 324 | 31 | 82 | 37 |
| `TrackController#track_click` | 18,240 | 9 | 39 | 80 | 1 | 0 | 1 |
| `CoursesController#confirm_apply` | 15,627 | 33 | 94 | 152 | 11 | 35 | 12 |
| `Candidates::SavedCoursesController#sign_in` | 12,539 | 18 | 53 | 92 | 5 | 22 | 5 |
| `Courses::ProvidersController#show` | 12,205 | 34 | 89 | 160 | 12 | 41 | 13 |
| `GeolocationSuggestionsController#index` | 12,203 | 18 | 131 | 181 | 10 | 1 | 2 |
| `HomepageController#index` | 5,768 | 45 | 110 | 185 | 12 | 67 | 7 |

On 24 September, with the k6 hours left out, `ResultsController#index` was p50 669, p95 1,395, p99 2,193, with
135 queries a request.

The search results page is the only database-heavy endpoint. Every other endpoint in the table stays under
350ms at p99.

Resources (Grafana, `publish-production` web pods; Azure Monitor):

| | Opens | 24 Sep |
|---|---|---|
| Memory, busiest pod | 855 MiB of 1,024 MiB (84%) | 678 MiB of 4,096 MiB |
| CPU, busiest pod | 0.14 of 1 core | 0.18 of 1 core |
| CPU, all web pods | peak 1.87 cores at 04:04 | peak 1.79 cores at 04:07 |
| Pod restarts | 0 | 0 |
| Postgres CPU, max / average | 13.8% / 2.3% | 33.5% / 4.5% |
| Postgres memory, max | 37% | 48% |
| Postgres active connections, max / average | 81 / 45 | 53 / 35 |
| Postgres IOPS, max | 39 | 85 |

CPU peaks at about 04:05 on both days, outside candidate hours; the cause was not identified. The memory peak,
84% of the 1Gi limit, came at the same moment on a pod started before midnight. Pods started
by the day's deployments stayed at or under 599 MiB.

### Searches

Non-bot `/results` requests (Front Door). A location search is one with a non-empty `location` parameter.

| | Opens requests | Opens p50 / p95 / p99 | 24 Sep requests | 24 Sep p50 / p95 / p99 |
|---|---|---|---|---|
| Location | 10,867 | 365 / 928 / 1,372 | 2,808 | 731 / 1,631 / 2,633 |
| Non-location | 8,993 | 339 / 1,283 / 1,749 | 3,895 | 752 / 2,276 / 2,741 |

Location searches grew 3.9 times, non-location 2.3 times. Neither returned a 5xx.

Geocoding cache (Logit):

| | Opens | 24 Sep |
|---|---|---|
| Address lookups, hit rate | 86.8% (14,647 hit, 2,219 miss) | 82.0% |
| Autocomplete suggestions, hit rate | 74.5% (9,084 hit, 3,114 miss) | 71.4% |
| Failed lookups | 0 | 0 |

Each miss is a Google call: about 2,200 geocodes and 3,100 autocomplete requests on opens day.

The most-searched places were out of scope this year and were not collected.

### Errors

| | Opens | 24 Sep | Source |
|---|---|---|---|
| 5xx at the edge | 19 | 3 | Front Door |
| 429 at the edge | 2,499 | 11,099 | Front Door |
| Sentry issues (production) | 15 | 1 | Sentry |
| Logged exceptions | 8,576 | 3,215 | Logit |

- 8,238 of the logged exceptions were `ActionController::RoutingError`: scanners and missing icons
  (`/index.php`, `/cgi-bin/…`, `/favicon.ico`).
- 326 were rescued errors: `ActiveRecord::RecordNotFound` 302, `Pagy::OverflowError` 18,
  `ActionController::InvalidAuthenticityToken` 3, `ActionController::UnknownFormat` 3. Rescued errors were first
  logged on 1 October (`093667575`), so 24 September has none to compare.
- 7 came from the Redis connection failures at 08:24–08:25, and 5 were one-offs.
- On 24 September the Front Door WAF blocked 9,236 k6 requests, which account for most of that day's 429s.
  The source of the opens-day 429s is not confirmed.

### Bots and unusual traffic

| | Opens requests | Source |
|---|---|---|
| `ShapBot/0.1.0`, all from the US | 66,059 | Front Door |
| `/ping` monitor | 20,260 | Front Door |
| `Amzn-SearchBot` | 8,649 | Front Door |
| Blocked by the Front Door WAF, three busiest rules | 2,327 | Front Door WAF log |

Across all traffic, the busiest single IP address sent 6.5% of requests and the top 10 sent 28.9%. The two
crawlers alone sent 31%.

### Against the load test

The k6 Peak scenario (`load_testing/README.md`) assumes 150 requests a second sustained, with p95 under 3s and
errors under 1%. On opens day:

- The busiest non-bot minute ran at 5.7 requests a second, and the busiest minute of all traffic at 15.5. Even
  the busiest second, a scanner, stayed under 150.
- Non-bot p95 stayed under 1.3s on the busiest Find paths, and 5xx were 0.008% of requests.

For the next load test:

- Keep 150 requests a second as the Peak Surge target; it is about 10 times the busiest minute of all traffic.
- Weight journeys by what candidates did: search results about a fifth of non-bot requests, with location and
  non-location searches roughly equal.
- Watch pod memory against the 1Gi limit. It was the closest margin on the day.
- Add crawler traffic: the two crawlers sent 31% of real requests.

### Surprises

- Worker Redis dropped connections for about 15 seconds at 08:24, outside its patch window, and Find pages
  that touch Redis returned errors.
- Six deployments went out during opening day, three in 44 minutes.
- One crawler, ShapBot, sent more requests than all non-bot search traffic combined.
- Front Door logged k6 traffic on 24 September, but no app log line that day carries the k6 user agent.

### How this was collected

| Source | How | Kept for |
|---|---|---|
| Front Door access and WAF logs | Log Analytics workspace `s189p01-fttc-svc-domains-fd-log`, `AzureDiagnostics` where `Category` is `FrontDoorAccessLog` or `FrontDoorWebApplicationFirewallLog`. Query with `az monitor log-analytics query` | 30 days |
| Postgres, Redis, Front Door metrics | `az monitor metrics list` on each resource, 1-minute interval | 93 days |
| Logit | OpenSearch Dashboards, index `filebeat-*`, filter `kubernetes.deployment.name : publish-production`. App fields sit under `app.*`: `app.payload.controller`, `app.duration_ms`, `app.payload.db_runtime`, `app.payload.view_runtime`, `app.payload.queries_count`. `app.message` is a keyword field, so match it by prefix | about 1 month |
| Grafana | The Prometheus data source, filtered to pods matching `publish-production-[a-z0-9]+-[a-z0-9]{5}`. `bat-production` also runs Apply, Register and other services | full detail 30 days, 5-minute 60 days |
| Sentry | Project 1377944, `environment:production` | plan-dependent |
| Cluster | `kubectl -n bat-production get deployments` after production PIM | live only |

Production PIM covers the `bat-production` namespace only, so Thanos in the monitoring namespace is not
reachable with it. Front Door and Logit expire first: collect them within a month of opening.
