# Find peak load test — 24 September 2026

## Run overview

This peak-load test ran against the staging Find teacher training service from approximately 09:44 to 10:00 BST. Total runtime was 15 minutes 22 seconds.

The closed, concurrent-user scenario started with 50 virtual users (VUs), ramped to 150 and then 200 VUs, held at 200 VUs for five minutes, and finally ramped down to zero.

This run followed the earlier staging test that used 32 application replicas. The k6 artifacts do not record the live replica count, so the deployment state should be confirmed separately if the run needs to be reproduced exactly.

## Infrastructure observations

The infrastructure review found no visible bottleneck in ingress or Front Door. Database runtime remained stable throughout the load increase, and the available database statistics did not show an obvious capacity problem.

These observations were gathered outside k6 and are recorded here for context. The k6 timings show where the client waited, but cannot independently identify which internal component caused that wait.

## Overall results

| Metric | Result |
|---|---:|
| Total requests | 23,391 |
| Average request rate | 25.36 requests/second |
| Median response time | 2.04 seconds |
| Average response time | 4.53 seconds |
| p90 response time | 11.12 seconds |
| p95 response time | 16.84 seconds |
| Maximum response time | 60.00 seconds |
| Failed HTTP requests | 48 (0.205%) |
| Requests exceeding their endpoint target | 8,487 of 20,833 (40.74%) |

The HTTP failure-rate threshold of less than 1% passed. The p95 response-time threshold of less than 3 seconds failed.

Of the 48 HTTP failures, 29 were 60-second request timeouts and 19 were connections reset by the remote side. There were no 4xx, 5xx, or 429 responses.

Almost all response time was spent waiting for the first response byte: `http_req_waiting` p95 was 16.84 seconds, while connection, TLS, sending, and response-download timings remained small.

## Behaviour as load increased

| Test stage | Average VUs | Request rate | Median | p95 | Over endpoint target |
|---|---:|---:|---:|---:|---:|
| Initial load | 50.0 | 20.4/s | 0.80s | 1.92s | 0.2% |
| Ramp from 50 to 150 | 99.8 | 26.0/s | 1.47s | 5.78s | 21.8% |
| Ramp from 150 to 200 | 174.5 | 27.2/s | 2.88s | 15.40s | 50.2% |
| Hold at 200 | 200.0 | 27.0/s | 2.72s | 22.09s | 48.5% |

Throughput again plateaued at approximately 26–27 requests per second. Increasing concurrency beyond roughly 100 VUs primarily increased latency rather than completed request throughput.

Compared with the two earlier archived peak runs, this run had the lowest aggregate p95 and the lowest 200-VU hold p95. However, throughput remained within the same narrow range, so the underlying scaling limit was still present.

## Content checks

The run recorded 66 content-check errors. All were for the `Age group` assertion on basic-search result pages, and the run also recorded exactly 66 basic searches with zero results. The missing course-listing text is expected on an empty-results page, so these should not be treated as application failures.

Empty-result rates remained below their 25% thresholds:

- Basic search: 4.18%
- Multi-filter search: 3.57%
- Advanced-filter search: 12.81%

## Conclusion

The service remained available, with an HTTP failure rate of 0.205%, but it did not produce materially more throughput as concurrency increased. At the 200-VU hold, throughput was 27.0 requests per second and p95 latency was 22.09 seconds.

No ingress, Front Door, or database-runtime bottleneck was visible in the accompanying infrastructure investigation. Further diagnosis should therefore focus on application-level request queueing, per-pod traffic distribution, Rails/Puma concurrency, and timings for individual application operations or downstream dependencies.

## Files

- [Time-series dashboard](./find-peak-dashboard.html)
- [Aggregate HTML report](./find-load-test-report.html)
- [Aggregate JSON summary](./find-load-test-summary.json)
- [Compressed raw time-series data](./find-peak-timeseries.json.gz)
