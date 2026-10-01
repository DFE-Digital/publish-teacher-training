# Find Opens peak load test — 25 September 2026

## Run overview

This peak-load test ran against the staging Find teacher training service from approximately 18:38 to 18:54 BST. Total runtime was 15 minutes 17 seconds.

The closed, concurrent-user scenario used the following stages:

1. Hold at 50 virtual users (VUs) for 1 minute.
2. Ramp from 50 to 150 VUs over 2 minutes.
3. Ramp from 150 to 200 VUs over 5 minutes.
4. Hold at 200 VUs for 5 minutes.
5. Ramp down to zero over 2 minutes, with a 30-second graceful ramp-down.

This test was intended to represent Find Opens peak traffic rather than push the service to the 400-VU stress-test limit. It ran after request-scoped caching for cycle settings and feature flags had been introduced to reduce repeated synchronous worker-Redis reads.

The repository staging configuration specified 36 application replicas with a 1 GiB memory limit and a `GP_Standard_D8ds_v5` PostgreSQL server. The k6 artifacts do not record the live deployment state, so these values should be confirmed separately if the run needs to be reproduced exactly.

## Overall results

| Metric | Result |
|---|---:|
| Total requests | 41,156 |
| Average request rate | 44.88 requests/second |
| Median response time | 1.65 seconds |
| Average response time | 1.86 seconds |
| p90 response time | 3.02 seconds |
| p95 response time | 4.99 seconds |
| Maximum response time | 30.20 seconds |
| Failed HTTP requests | 206 (0.50%) |
| Requests exceeding their endpoint target | 3,614 of 36,441 (9.92%) |

The HTTP failure-rate threshold of less than 1% passed. The aggregate p95 threshold of less than 3 seconds failed.

All 206 HTTP failures were connections reset by the remote side. The remaining 40,950 requests returned HTTP 200. There were no 4xx, 5xx, 429, or 60-second client-timeout responses.

Almost all response time was spent waiting for the first response byte. `http_req_waiting` p95 was 4.99 seconds, while connection, TLS, request-send, and response-download timings remained small.

## Behaviour as load increased

| Test stage | Average VUs | Request rate | Median | p95 | HTTP failure rate | Over endpoint target |
|---|---:|---:|---:|---:|---:|---:|
| Initial load | 50.0 | 26.8/s | 0.27s | 0.76s | 0.00% | 0.0% |
| Ramp from 50 to 150 | 99.8 | 42.7/s | 0.49s | 1.74s | 0.02% | 2.4% |
| Ramp from 150 to 200 | 174.5 | 48.9/s | 1.70s | 5.15s | 0.87% | 11.0% |
| Hold at 200 | 200.0 | 49.0/s | 2.27s | 6.76s | 0.52% | 14.1% |

Performance was healthy through the 50-to-150 VU ramp. The aggregate latency objective started to be exceeded during the ramp to 200 VUs, although the transport failure rate remained below 1% throughout the 200-VU hold.

Throughput stopped increasing at approximately 49 requests per second: the 150-to-200 ramp delivered 48.9 requests per second and the 200-VU hold delivered 49.0. Additional concurrency at that point increased latency rather than completed throughput.

## Comparison with the previous peak run

The preceding archived peak test on 24 September used the same VU stages and had nearly the same duration. It was performed before the request-scoped Redis caching change.

| Metric | Previous peak | This peak | Change |
|---|---:|---:|---:|
| Total requests | 23,391 | 41,156 | +76% |
| Average request rate | 25.36/s | 44.88/s | +77% |
| Median response time | 2.04s | 1.65s | -19% |
| Average response time | 4.53s | 1.86s | -59% |
| p95 response time | 16.84s | 4.99s | -70% |
| HTTP failure rate | 0.21% | 0.50% | +0.29 percentage points |
| Requests over endpoint target | 40.74% | 9.92% | -30.82 percentage points |
| 200-VU hold request rate | 27.0/s | 49.0/s | +81% |
| 200-VU hold p95 | 22.09s | 6.76s | -69% |

This is strong evidence that eliminating repeated Redis reads materially improved throughput and response times, assuming the deployment and surrounding infrastructure were otherwise comparable. The HTTP failure rate increased slightly but remained within its threshold.

## Endpoint observations

Search remained the slowest part of the journey:

- Basic search had a p95 of approximately 10.7 seconds, rising to approximately 12.0 seconds in the full-journey sample.
- Multi-filter search had a p95 of approximately 9.5 seconds.
- Apply-journey search and course requests had a p95 of approximately 3.4 seconds.
- Advanced-filter search had a p95 of approximately 2.8 seconds.
- Pagination had a p95 of approximately 2.7 seconds.
- Course-detail requests had a p95 of approximately 1.6 seconds.
- The homepage had a p95 of approximately 0.20 seconds.

The remaining latency is therefore concentrated in basic and multi-filter searches rather than affecting all page types equally.

## Content checks

The run recorded 4,652 content-check errors:

- 2,349 expected the course page's `apply-section` to contain “Apply for this course”.
- 2,303 expected the course page's `apply-button` to contain “Apply for this course”.

Every one of these responses had HTTP status 200. The checks assume that applications are open, which is not correct for the Find Opens phase. They are phase-sensitive test expectations and should not be treated as application or transport failures.

No search returned an empty result count during this run, and all three empty-result thresholds passed.

## Load-model caveat

This is a closed, VU-based test. The scenario uses 200 concurrent users; it does not generate 200 requests per second. Although the scenario source contains a comment describing a “200 RPS target”, the 200-VU hold actually delivered approximately 49 requests per second.

If the Find Opens acceptance target is expressed in requests per second, it should be tested separately with a `constant-arrival-rate` or `ramping-arrival-rate` scenario.

## Conclusion

This is a substantial improvement over the previous peak run. The service remained available at 200 concurrent users with a 0.52% hold-stage failure rate, while the hold-stage p95 fell from 22.09 seconds to 6.76 seconds and throughput increased from 27.0 to 49.0 requests per second.

However, the aggregate p95 objective still failed, basic and multi-filter searches remained slow, and throughput again plateaued at approximately 49 requests per second. Further investigation should focus on the search request path and the source of the connection resets. If readiness is defined as a target RPS rather than concurrent users, a rate-based test is also required.

## Files

- [Time-series dashboard](./find-peak-dashboard.html)
- [Aggregate HTML report](./find-load-test-report.html)
- [Aggregate JSON summary](./find-load-test-summary.json)
