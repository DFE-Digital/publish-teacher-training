# Find peak load test — 22 September 2026, 32 replicas

## Run overview

This was a peak-load test against the staging Find teacher training service. It ran for approximately 15 minutes 23 seconds, from 18:36 to 18:51 BST.

The test repeated the same scenario as the earlier [16-replica peak run](../26-09-22-17_49-peak/README.md):

1. Start and hold at 50 virtual users (VUs) for 1 minute.
2. Ramp from 50 to 150 VUs over 2 minutes.
3. Ramp from 150 to 200 VUs over 5 minutes.
4. Hold at 200 VUs for 5 minutes.
5. Ramp down to 0 VUs over 2 minutes, with a 30-second graceful ramp-down.

## Infrastructure change

- Application replicas: 32 pods, doubled from 16 in the previous run
- Pod memory limit: 1 GB per pod
- Database tier: `GP_Standard_D8ds_v5`

The reported change for this comparison was the replica count. The database tier and per-pod memory limit are recorded as unchanged from the previous run. No new pod or database utilisation measurements were supplied with these test artifacts.

## Overall results

| Metric | Result |
|---|---:|
| Total requests | 24,228 |
| Average request rate | 26.26 requests/second |
| Median response time | 1.60 seconds |
| Average response time | 4.29 seconds |
| p90 response time | 9.36 seconds |
| p95 response time | 18.58 seconds |
| Maximum response time | 60.00 seconds |
| Failed HTTP requests | 77 (0.318%) |
| Responses exceeding their 2- or 3-second target | 7,035 of 21,445 (32.80%) |

The HTTP failure-rate threshold of less than 1% passed. The response-time threshold of p95 below 3 seconds and the custom latency-based error-rate threshold failed. No 4xx, 5xx, or 429 responses were recorded by the custom checks.

## Comparison with 16 replicas

| Metric | 16 replicas | 32 replicas | Change |
|---|---:|---:|---:|
| Total requests | 23,039 | 24,228 | 5.2% more |
| Average request rate | 25.08/s | 26.26/s | 4.7% higher |
| Median response time | 1.78s | 1.60s | 10.3% lower |
| Average response time | 4.62s | 4.29s | 7.1% lower |
| p90 response time | 11.69s | 9.36s | 19.9% lower |
| p95 response time | 22.77s | 18.58s | 18.4% lower |
| Failed HTTP requests | 36 (0.156%) | 77 (0.318%) | Higher, but below 1% |
| Over endpoint response-time target | 31.74% | 32.80% | 1.06 percentage points higher |

The whole-run latency distribution improved, particularly at p90 and p95. Throughput improved by less than 5%, despite twice as many application replicas. The HTTP failure rate roughly doubled, although it remained comfortably below the 1% threshold.

## Behaviour by load stage

| Stage | 16-replica RPS | 32-replica RPS | 16-replica p95 | 32-replica p95 |
|---|---:|---:|---:|---:|
| Initial 50 VUs | 19.5/s | 20.6/s | 2.40s | 1.97s |
| Ramp from 50 to 150 | 25.1/s | 27.9/s | 7.00s | 5.29s |
| Ramp from 150 to 200 | 26.1/s | 28.5/s | 24.10s | 16.18s |
| Hold at 200 | 27.2/s | 27.5/s | 27.77s | 31.40s |

The additional replicas improved latency and throughput during ramp-up. At approximately 88 VUs, p95 was 2.98 seconds, compared with 4.01 seconds in the previous run. At approximately 112 VUs, p95 was 5.66 seconds, compared with 8.07 seconds previously.

The sustained 200-VU period behaved differently:

- Throughput increased only from 27.2 to 27.5 requests per second.
- Median latency improved from 2.46 to 1.85 seconds.
- p90 improved slightly from 14.59 to 13.82 seconds.
- p95 worsened from 27.77 to 31.40 seconds.
- HTTP failures increased from approximately 0.20% to 0.59% during the hold.

Typical requests therefore became faster, but the slowest requests became slower and more likely to fail. Nearly all journey groups had a worse p95 during the sustained 200-VU period, although their median response times improved.

## Interpretation

Doubling the replicas improved ordinary response times and delayed the sharpest degradation during ramp-up. It did not materially increase sustained peak throughput or remove the long-latency tail.

The service still reached a throughput plateau of roughly 27 to 30 requests per second as concurrency increased. The limited throughput gain from twice as many replicas suggests that application replica count was not the only constraint. Possible shared constraints include request queueing, database connection-pool or query contention, load distribution, and downstream dependencies. Infrastructure telemetry is needed to distinguish between these possibilities.

## Content-check note

This run was completed before the empty-results content-check fix. Its 97 content errors were the known false positives caused by checking for an `Age group` course-card field on valid empty-result pages. They should not be interpreted as application failures. The load-test code was corrected after this run so that course-card content is checked only when the result count is greater than zero.

## Conclusion

The 32-replica configuration performed better overall than the 16-replica configuration, with an 18% lower whole-run p95 and a 20% lower p90. However, the improvement was concentrated in the ramp-up period. At the sustained 200-VU peak, throughput was almost unchanged and p95 latency was worse.

The result does not support application replicas as the sole bottleneck. The next comparison should retain application and database telemetry for the same time window, particularly request-queue depth, pod CPU, database connections, slow queries, locks, and downstream timings.

## Files

- [Time-series dashboard](./find-peak-dashboard.html)
- [Aggregate HTML report](./find-load-test-report.html)
- [Aggregate JSON summary](./find-load-test-summary.json)
- [Compressed raw time-series data](./find-peak-timeseries.json.gz)
