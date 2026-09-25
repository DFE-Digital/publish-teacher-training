# Find stress test — 25 September 2026

## Run overview

This stress test ran against the staging Find teacher training service from approximately 17:45 to 18:11 BST. Total runtime was 25 minutes 19 seconds.

The closed, concurrent-user scenario used the following stages:

1. Ramp from 100 to 200 virtual users (VUs) over 2 minutes.
2. Ramp from 200 to 300 VUs over 5 minutes.
3. Ramp from 300 to 400 VUs over 10 minutes.
4. Hold at 400 VUs for 5 minutes.
5. Ramp down to zero over 3 minutes, with a 30-second graceful ramp-down.

This was the first archived stress run after adding request-scoped caching for cycle settings and feature flags. The change was intended to remove repeated synchronous reads from the worker Redis instance while rendering a single request.

The repository staging configuration specified 36 application replicas with a 1 GiB memory limit and a `GP_Standard_D8ds_v5` PostgreSQL server. The k6 artifacts do not record the live deployment state, so these values should be confirmed separately if the run needs to be reproduced exactly.

## Overall results

| Metric | Result |
|---|---:|
| Total requests | 71,409 |
| Average request rate | 47.01 requests/second |
| Median response time | 4.11 seconds |
| Average response time | 4.96 seconds |
| p90 response time | 8.47 seconds |
| p95 response time | 15.25 seconds |
| Maximum response time | 38.65 seconds |
| Failed HTTP requests | 1,446 (2.02%) |
| Requests exceeding their endpoint target | 40,510 of 63,009 (64.29%) |

Both principal thresholds failed: p95 was above 3 seconds and the HTTP failure rate was above 1%.

All 1,446 HTTP failures were connections reset by the remote side. The remaining 69,963 requests returned HTTP 200. There were no 4xx, 5xx, 429, or 60-second client-timeout responses.

Almost all response time was spent waiting for the first response byte. `http_req_waiting` p95 was 15.25 seconds, while connection, TLS, request-send, and response-download timings remained small.

## Behaviour as load increased

| Test stage | Average VUs | Request rate | Median | p95 | HTTP failure rate | Over endpoint target |
|---|---:|---:|---:|---:|---:|---:|
| Ramp from 100 to 200 | 149.8 | 46.6/s | 1.37s | 4.01s | 0.00% | 9.0% |
| Ramp from 200 to 300 | 249.5 | 48.2/s | 3.08s | 9.83s | 0.46% | 53.4% |
| Ramp from 300 to 400 | 349.5 | 47.7/s | 4.63s | 18.75s | 4.19% | 76.7% |
| Hold at 400 | 400.0 | 48.6/s | 6.09s | 20.10s | 1.22% | 80.0% |

Throughput remained between 46.6 and 48.6 requests per second throughout every increasing-load stage. The Redis improvement raised the apparent throughput ceiling, but increasing concurrency beyond the first stage still produced higher latency rather than materially more completed requests.

The HTTP failure rate peaked during the 300-to-400 VU ramp rather than during the 400-VU hold. Of the 1,446 connection resets, 1,200 occurred during that ramp and 178 during the hold. This transient concentration should be correlated with application, ingress, Front Door, and Redis telemetry for the same period.

## Comparison with the previous stress run

The preceding stress run on 24 September used the same VU stages and had nearly the same duration. It was performed before the request-scoped Redis caching change.

| Metric | Previous run | This run | Change |
|---|---:|---:|---:|
| Total requests | 42,217 | 71,409 | +69% |
| Average request rate | 27.75/s | 47.01/s | +69% |
| Average response time | 9.46s | 4.96s | -48% |
| p95 response time | 46.62s | 15.25s | -67% |
| HTTP failure rate | 3.19% | 2.02% | -1.17 percentage points |
| 400-VU hold request rate | 28.7/s | 48.6/s | +69% |
| 400-VU hold p95 | 59.96s | 20.10s | -66% |
| 400-VU hold failure rate | 5.27% | 1.22% | -4.05 percentage points |

This is strong evidence that removing repeated Redis reads materially improved capacity and tail latency, assuming the deployment and surrounding infrastructure were otherwise comparable. It did not remove the scaling ceiling: the new plateau is approximately 48 requests per second.

## Endpoint observations

Search requests remained the slowest part of the tested journey:

- Basic search had a p95 of approximately 30.1 seconds.
- Multi-filter search had a p95 of approximately 25.0 seconds.
- Apply-journey search and course requests had a p95 of approximately 8.9 seconds.
- Pagination had a p95 of approximately 7.1 seconds.
- Advanced-filter search had a p95 of approximately 6.9 seconds.
- Course-detail requests had a p95 of approximately 4.1 seconds.
- The homepage had a p95 of approximately 0.26 seconds.

This distribution suggests that the remaining limit is concentrated in search-related work rather than affecting all pages equally. k6 cannot identify the internal cause, so this should be correlated with per-endpoint Rails timings and dependency metrics.

## Content checks

The run recorded 7,873 content-check errors:

- 3,942 expected the course page's `apply-section` to contain “Apply for this course”.
- 3,931 expected the course page's `apply-button` to contain “Apply for this course”.

Every one of these responses had HTTP status 200. The run occurred after the 2026 application deadline on 15 September and before Find closed on 28 September, when course pages show closed-cycle application content instead. These are phase-sensitive test expectations and should not be treated as application or transport failures.

No search returned an empty result count during this run, and all three empty-result thresholds passed.

## Conclusion

The request-scoped Redis caching change coincided with a clear performance improvement: throughput increased by approximately 69%, aggregate p95 fell by approximately 67%, and the 400-VU hold failure rate fell from 5.27% to 1.22%.

The service still reached a plateau at approximately 48 requests per second. As load rose from roughly 150 to 400 VUs, hold-stage p95 reached 20.10 seconds and 80% of measured requests exceeded their endpoint-specific target. The next investigation should focus on the search request path and the source of the connection resets, while comparing worker Redis Server Load, operations per second, latency, and CPU with the previous run.

## Files

- [Time-series dashboard](./find-stress-dashboard.html)
- [Aggregate HTML report](./find-load-test-report.html)
- [Aggregate JSON summary](./find-load-test-summary.json)
- [Compressed raw time-series data](./find-stress-timeseries.json.gz)
