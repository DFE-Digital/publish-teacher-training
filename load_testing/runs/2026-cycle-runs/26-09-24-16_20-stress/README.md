# Find stress test — 24 September 2026

## Run overview

This stress test ran against the staging Find teacher training service from approximately 16:20 to 16:46 BST. Total runtime was 25 minutes 21 seconds.

The closed, concurrent-user scenario used the following stages:

1. Ramp from 100 to 200 virtual users (VUs) over 2 minutes.
2. Ramp from 200 to 300 VUs over 5 minutes.
3. Ramp from 300 to 400 VUs over 10 minutes.
4. Hold at 400 VUs for 5 minutes.
5. Ramp down to zero over 3 minutes, with a 30-second graceful ramp-down.

The repository staging configuration at the time of analysis specified 36 application replicas. The k6 artifacts do not record the live deployment state, so this should be confirmed separately if the run needs to be reproduced exactly.

## Infrastructure context

The investigation accompanying the preceding peak run found no visible bottleneck in ingress or Front Door, while database runtime remained stable as load increased. No infrastructure change was reported for this stress run.

These observations were gathered outside k6. The k6 timings demonstrate that requests waited for a response, but cannot independently locate that waiting within the application path.

## Overall results

| Metric | Result |
|---|---:|
| Total requests | 42,217 |
| Average request rate | 27.75 requests/second |
| Median response time | 3.14 seconds |
| Average response time | 9.46 seconds |
| p90 response time | 28.90 seconds |
| p95 response time | 46.62 seconds |
| Maximum response time | 60.03 seconds |
| Failed HTTP requests | 1,348 (3.19%) |
| Requests exceeding their endpoint target | 18,887 of 36,792 (51.33%) |

Both principal thresholds failed: p95 was above 3 seconds and the HTTP failure rate was above 1%.

Of the 1,348 HTTP failures, 1,210 were 60-second request timeouts and 138 were connections reset by the remote side. All other requests returned HTTP 200; there were no 4xx, 5xx, or 429 responses.

Almost all response time was spent waiting for the first response byte. `http_req_waiting` p95 was 46.61 seconds, while connection, TLS, request-send, and response-download timings remained small.

## Behaviour as load increased

| Test stage | Average VUs | Request rate | Median | p95 | HTTP failure rate | Over endpoint target |
|---|---:|---:|---:|---:|---:|---:|
| Ramp from 100 to 200 | 149.8 | 28.6/s | 2.45s | 9.98s | 0.03% | 44.1% |
| Ramp from 200 to 300 | 249.5 | 28.5/s | 3.89s | 23.82s | 1.38% | 55.6% |
| Ramp from 300 to 400 | 349.5 | 28.1/s | 3.58s | 52.98s | 3.91% | 53.6% |
| Hold at 400 | 400.0 | 28.7/s | 3.84s | 59.96s | 5.27% | 53.8% |

Throughput remained between 28.1 and 28.7 requests per second throughout every increasing-load stage. Additional concurrency therefore produced longer queues and more failures, rather than additional completed throughput.

Compared with the preceding 200-VU peak run, the 400-VU hold delivered only about 6% more throughput (28.7 versus 27.0 requests per second). Its p95 latency was approximately 2.7 times higher (59.96 versus 22.09 seconds), and its HTTP failure rate increased from approximately 0.31% to 5.27%.

The configured reliability threshold was crossed during the 200-to-300 VU ramp. By the 300-to-400 VU ramp, p95 was above 50 seconds and failures were approaching 4%.

## Content checks

The run recorded 104 content-check errors. All were for the `Age group` assertion on basic-search pages, and the run also recorded exactly 104 basic searches returning zero results. These are expected empty-result pages and should not be treated as application failures.

Empty-result rates remained below their 25% thresholds:

- Basic search: 3.32%
- Multi-filter search: 3.97%
- Advanced-filter search: 13.82%

## Conclusion

This run demonstrates a practical throughput ceiling of approximately 28–29 requests per second for the tested path and deployment. Increasing concurrency from roughly 150 to 400 VUs did not materially increase throughput, while latency and transport-level failures rose sharply.

The service was already outside its response-time objective during the first stress stage. Its failure-rate objective was breached between 200 and 300 VUs, and the 400-VU hold produced a p95 close to the 60-second client timeout.

Because the prior investigation did not identify ingress, Front Door, or database-runtime saturation, the next investigation should correlate k6 timings with per-pod request counts, Puma queue time, per-pod CPU throttling, database connection-pool checkout time, and Rails request breakdowns for application code, cache, Redis, logging, and downstream operations.

## Files

- [Time-series dashboard](./find-stress-dashboard.html)
- [Aggregate HTML report](./find-load-test-report.html)
- [Aggregate JSON summary](./find-load-test-summary.json)
- [Compressed raw time-series data](./find-stress-timeseries.json.gz)
