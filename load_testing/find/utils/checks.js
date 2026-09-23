import { check, group } from 'k6'
import { Trend, Rate, Counter } from 'k6/metrics'

const findResponseTimes = new Trend('find_response_time_trend')
const findErrorRate = new Rate('find_error_rate')
const findErrors4xx = new Rate('find_errors_4xx')
const findErrors5xx = new Rate('find_errors_5xx')
const findTimeouts = new Rate('find_timeouts')
const findRateLimited = new Rate('find_rate_limited')
const findContentErrors = new Counter('find_content_errors')
const findSuccessRate = new Rate('find_success_rate')
const findEmptyResults = new Rate('find_empty_results')

export function findPerformanceCheck (response, name, threshold = 3000) {
  findResponseTimes.add(response.timings.duration)

  const is4xx = response.status >= 400 && response.status < 500
  const is5xx = response.status >= 500
  const isTimeout = response.timings.duration >= threshold
  const isRateLimit = response.status === 429
  const isSuccess = response.status === 200 && response.timings.duration < threshold

  const errorType = (() => {
    if (is4xx) return '4xx'
    if (is5xx) return '5xx'
    if (isTimeout) return 'timeout'
    return 'none'
  })()

  findErrors4xx.add(is4xx)
  findErrors5xx.add(is5xx)
  findTimeouts.add(isTimeout)
  findRateLimited.add(isRateLimit)
  findSuccessRate.add(isSuccess)

  findErrorRate.add(!isSuccess)

  check(response, {
    [`${name}: status is 200`]: (r) => r.status === 200,
    [`${name}: response time < ${threshold}ms`]: (r) => r.timings.duration < threshold,
    [`${name}: no server errors (5xx)`]: (r) => r.status < 500,
    [`${name}: no client errors (4xx)`]: (r) => r.status < 400,
    [`${name}: not rate limited (429)`]: (r) => r.status !== 429,
    [`${name}: response size > 0`]: (r) => r.body.length > 0
  }, {
    endpoint: name,
    service: 'find',
    success: isSuccess ? 'true' : 'false',
    error_type: errorType
  })

  return isSuccess
}

export function findContentCheck (response, checkName, expectedContent) {
  const hasContent = response.body.includes(expectedContent)

  if (!hasContent) {
    findContentErrors.add(1, {
      check_name: checkName,
      expected_content: expectedContent.substring(0, 50),
      status: response.status
    })
  }

  return check(response, {
    [`Find ${checkName}: contains expected content`]: (r) => r.body.includes(expectedContent),
    [`Find ${checkName}: content length > 100 chars`]: (r) => r.body.length > 100
  }, {
    content_check: checkName,
    service: 'find'
  })
}

export function findResultCount (response, checkName) {
  // A results page always prints a count, even when it reads "0 results". The
  // check asks only that the page rendered. An empty search is normal, so the
  // count feeds a rate instead of failing the request. A search that is always
  // empty breaks the find_empty_results threshold, which is the real fault.
  const match = response.body.match(/([0-9][0-9,]*) results/)
  const rendered = match !== null
  const resultCount = rendered ? Number(match[1].replace(/,/g, '')) : null

  if (!rendered) {
    findContentErrors.add(1, {
      check_name: checkName,
      expected_content: 'result count',
      status: response.status
    })
  } else {
    findEmptyResults.add(resultCount === 0, { check_name: checkName })
  }

  check(response, {
    [`Find ${checkName}: results page rendered`]: () => rendered,
    [`Find ${checkName}: content length > 100 chars`]: (r) => r.body.length > 100
  }, {
    content_check: checkName,
    service: 'find'
  })

  return resultCount
}

export function findErrorHandler (response, context) {
  return group('Find Error Analysis', function () {
    const errorDetails = {
      status: response.status,
      url: response.url,
      duration: response.timings.duration,
      size: response.body ? response.body.length : 0
    }

    if (response.status >= 400) {
      console.error(`Find Error [${context}]:`, JSON.stringify(errorDetails))
    }

    return errorDetails
  })
}
