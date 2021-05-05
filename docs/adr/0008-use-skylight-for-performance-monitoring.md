# 8. Use Skylight for performance monitoring

Date: 2021-04-26

## Status

Accepted

## Context

We need to decide between using skylight versus sentry for performance monitoring.

## Options

### 1. [Skylight](https://www.skylight.io/)

Skylight is a smart profiler for Ruby and Rails applications. It is an offering solely focusing on performance monitoring.

#### Pros

- Free for OSS
- Traces 100% of the requests to produce accurate results
- Clean dashboard providing easy to understand stats for each endpoint

#### Cons

- Lacks detailed information as it aggregates results
- Unable to breakdown more complex queries used in our app

### 2. [Sentry](https://sentry.io/features/distributed-tracing/)

Sentry is an error monitoring tool, which has expanded to include performance monitoring capabilities. The product offers 50k performance events per month in our current plan.

#### Pros

- Provides detailed insight into each request
- Can be configured to trace a subset of requests

#### Cons

- Very expensive considering our daily hits (400k/day)

## Decision

[There was an attempt](https://github.com/DFE-Digital/teacher-training-api/pull/1860) to use sentry, but we managed to fill up our quota in less than a day, and while Sentry does offer tracing a subset of requests, this would only allow us to trace less than 1% of our requests.

As such, we have decided to continue using skylight for performance monitoring.
