# Find & Publish Teacher Training - Load Testing

Comprehensive and scalable load testing suite for **Find** & (future) Publish Teacher Training services using [k6](https://grafana.com/products/k6/).

## Setup

1. **Install k6:**

*macOS*
```
  brew install k6
```

*Linux (Debian/Ubuntu)*

```
  sudo apt install k6
```

2. **Prepare environment variables (only for running on Grafana Cloud):**

```
   cd load_testing
   cp .env.example .env
   # Edit .env as needed for local, staging, or cloud runs.

   # Load environment variables (run this before each test session):
   set -o allexport; source .env; set +o allexport
```

## Environments

Set with `--env ENVIRONMENT=`:

| Name | Target |
| --- | --- |
| `local` | `http://find.localhost` |
| `qa` | `https://qa.find-teacher-training-courses.service.gov.uk` |
| `staging` | `https://staging.find-teacher-training-courses.service.gov.uk` |

`staging` is the default.

## Services

### Find Service

Every npm script runs `k6 run`, which generates the load from the machine you
run it on. Only the GitHub Actions workflow runs `k6 cloud`.

#### Local runs against a development machine

The load test needs one thing: the application listening on port 3001.

`./bin/dev` uses `Procfile.dev` by default, which starts the Rails server on
port 3001 and also starts Caddy. If you keep your own `Procfile.local`, then
`bin/dev` uses that file instead, so check that something in it serves port
3001.

The load test does not go through Caddy, and does not need its certificate.
Find only answers on the host `find.localhost`, so k6 resolves that name to
`127.0.0.1:3001` itself. A Caddy that fails to start does not stop a load test.

```
npm run find:dev:quick     # 10 users, 25 seconds
npm run find:dev:baseline
npm run find:dev:peak
npm run find:dev:stress
```

#### Runs against staging

The target is staging, but the load still comes from your own machine.

```
npm run find:quick
npm run find:baseline
npm run find:peak
npm run find:stress
npm run find:all           # baseline, then peak, then stress
```

#### Runs on Grafana Cloud

Start the **Find & Publish Load Tests** workflow in GitHub Actions and select a
scenario. The workflow runs `k6 cloud` against staging from the
`amazon:gb:london` load zone. It needs the `K6_CLOUD_API_TOKEN` secret.

To run a cloud test from your own machine, authenticate first and then call
`k6 cloud` directly:

```
npm run grafana:login
k6 cloud --env SCENARIO=baseline --env ENVIRONMENT=staging find/load-test.js
```

Set `GRAFANA_PROJECT_ID` to put the results in a specific Grafana Cloud project.

***

## Test Scenarios

### Quick Test
- **Users**: 10 concurrent
- **Duration**: 25 seconds
- **Purpose**: Confirm the suite and its content checks still work

### Baseline Test
- **Users**: 80 concurrent
- **Duration**: 14 minutes
- **Purpose**: Normal operations validation
- **Target RPS**: 5-10 sustained

### Peak Surge Test
- **Users**: 200 concurrent at peak
- **Duration**: 15 minutes
- **Purpose**: "Find opens" event (45k requests in 5 minutes)
- **Target RPS**: 150 sustained

### Stress Test
- **Users**: 400 concurrent
- **Duration**: 25 minutes
- **Purpose**: Breaking point identification
- **Target RPS**: 200+ sustained

***

## User Journey Mix

Based on production analytics:

- 51% Search operations (enhanced filtering)
- 42% Course page views (detailed browsing)
- 7% Apply clicks (conversion actions)

***

## Key Metrics

- **Response Time**: <3s for 95% of requests
- **Error Rate**: <1% during normal load
- **Throughput**: 150 RPS during peaks
- **Availability**: 99.9% uptime target

***

## Output & Monitoring

- **Local:**
  Results are printed in the terminal. Each run also writes
  `find-load-test-summary.json` and `find-load-test-report.html` to the
  directory you started it from.
- **Cloud (Grafana):**
  Real-time dashboards, historic tracking, and alerting available in Grafana Cloud (requires authentication).
