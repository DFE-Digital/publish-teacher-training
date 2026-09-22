# Find peak load test — 22 September 2026

## Run overview

This was a peak-load test against the staging Find teacher training service. It ran for approximately 15 minutes 19 seconds, from 17:46 to 18:01 BST.

The scenario used a closed, concurrent-user model:

1. Start and hold at 50 virtual users (VUs) for 1 minute.
2. Ramp from 50 to 150 VUs over 2 minutes.
3. Ramp from 150 to 200 VUs over 5 minutes.
4. Hold at 200 VUs for 5 minutes.
5. Ramp down to 0 VUs over 2 minutes, with a 30-second graceful ramp-down.

## Infrastructure

- Database tier: `GP_Standard_D8ds_v5`
- Application replicas: 16 pods
- Pod memory limit: 1 GB per pod
- Maximum observed pod memory: approximately 750 MB
- OOM kills: none
- Peak database CPU: 35%
- Database memory: approximately 36% during the run, compared with approximately 31% without load

Pod memory and the reported database CPU and memory metrics did not show resource exhaustion. These figures do not rule out other causes of latency, such as database query time, locks, connection-pool contention, application request queueing, or another downstream dependency.

## Overall results

| Metric | Result |
|---|---:|
| Total requests | 23,039 |
| Average request rate | 25.08 requests/second |
| Median response time | 1.78 seconds |
| Average response time | 4.62 seconds |
| p90 response time | 11.69 seconds |
| p95 response time | 22.77 seconds |
| Maximum response time | 60.00 seconds |
| Failed HTTP requests | 36 (0.156%) |
| Responses exceeding their 2- or 3-second target | 6,497 of 20,468 (31.74%) |

The HTTP failure-rate threshold of less than 1% passed. The response-time threshold of p95 below 3 seconds failed. No 4xx, 5xx, or 429 responses were recorded by the custom checks; the small number of HTTP failures appear to have been transport-level failures or timeouts.

## Behaviour as load increased

Latency increased substantially as more VUs were added, while throughput largely stopped increasing after around 100 VUs.

| Test stage | Average VUs | Request rate | Median | p95 | Responses over endpoint target |
|---|---:|---:|---:|---:|---:|
| Initial load | 50.0 | 19.5/s | 0.92s | 2.40s | 1.4% |
| Ramp from 50 to 150 | 99.8 | 25.1/s | 1.54s | 7.00s | 22.4% |
| Ramp from 150 to 200 | 174.5 | 26.1/s | 1.71s | 24.10s | 30.4% |
| Hold at 200 | 200.0 | 27.2/s | 2.46s | 27.77s | 44.0% |

The first clear breach occurred around 75 to 100 VUs. In the 30-second time buckets:

- At approximately 62 VUs, p95 was 2.67 seconds.
- At approximately 87 VUs, p95 was 4.01 seconds.
- At approximately 112 VUs, p95 was 8.07 seconds.
- At approximately 152 VUs, p95 was 16.78 seconds.

Doubling the load from approximately 100 to 200 VUs increased throughput by only about 8%, from 25.1 to 27.2 requests per second, while p95 latency increased from 7.0 to 27.8 seconds. This indicates substantial request queueing or saturation.

The slowdown affected every journey rather than one isolated endpoint. During the 200-VU hold, journey-level p95 response times ranged from approximately 21 seconds for the homepage to 37 seconds for multi-filter searches.

## Checks and test-data notes

The run recorded 97 content errors. These correspond to the 97 basic searches that returned no courses: the result page rendered correctly, but the `Age group` course-listing assertion was not present on an empty-results page. They should not be interpreted as application failures.

Empty-result rates remained below their 25% thresholds:

- Basic search: 6.37%
- Multi-filter search: 6.53%
- Advanced-filter search: 15.47%

The advanced-filter journey still used parameters that did not fully match the application's accepted funding and qualification parameters at the time of this run. Its performance traffic was valid, but it did not reliably verify the intended advanced-filter behaviour.

## Conclusion

The service remained available under peak load, and the database and pod memory metrics retained visible headroom. However, response latency degraded sharply from roughly 75 to 100 concurrent users onwards. At 200 VUs, additional concurrency produced very little extra throughput and p95 latency reached approximately 28 seconds.

Further investigation should correlate the affected time window with application request queues, database connection-pool usage, slow-query and lock data, and downstream service timings.

## Files

- [Time-series dashboard](./find-peak-dashboard.html)
- [Aggregate HTML report](./find-load-test-report.html)
- [Aggregate JSON summary](./find-load-test-summary.json)
- [Compressed raw time-series data](./find-peak-timeseries.json.gz)
