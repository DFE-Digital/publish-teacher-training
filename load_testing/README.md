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

2. **Prepare environment variables (only for running on Grafana cloud):**

```
   cd load_testing
   cp .env.example .env
   # Edit .env as needed for local, staging, or cloud runs.

   # Load environment variables (run this before each test session):
   set -o allexport; source .env; set +o allexport
```

## Services

### Find Service

#### Local/Development Runs

**Super quick local test (5 users, 10s):**
```
npm run find:dev
```

**Baseline, peak, and stress local:**
```
 npm run find:dev
 npm run find:dev:baseline
 npm run find:dev:peak
 npm run find:dev:stress
```

#### Running on Grafana

**Run baseline scenario in Grafana Cloud (250 concurrent users):**
```
npm run find:baseline
```
**Run peak surge scenario in Grafana Cloud (3000 concurrent users, 150 RPS):**
```
npm run find:peak
```
**Run stress scenario in Grafana Cloud (4000+ concurrent users):**
```
npm run find:stress
```

***

## Test Scenarios

### Baseline Test
- **Users**: 250 concurrent
- **Duration**: 14 minutes
- **Purpose**: Normal operations validation
- **Target RPS**: 5-10 sustained

### Peak Surge Test
- **Users**: 3000 concurrent at peak
- **Duration**: 15 minutes
- **Purpose**: "Find opens" event (45k requests in 5 minutes)
- **Target RPS**: 150 sustained

### Stress Test
- **Users**: 4000+ concurrent
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
  Results printed in terminal; JSON (`*-summary.json`) can be exported for deeper analysis.
- **Cloud (Grafana):**
  Real-time dashboards, historic tracking, and alerting available in Grafana Cloud (requires authentication).
