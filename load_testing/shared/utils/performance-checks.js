import { check } from 'k6';
import { Trend } from 'k6/metrics';

const responseTimes = new Trend('response_time_trend');

export function performanceCheck(response, name, threshold = 3000) {
  responseTimes.add(response.timings.duration);

  return check(response, {
    [`${name}: status is 200`]: (r) => r.status === 200,
    [`${name}: response time < ${threshold}ms`]: (r) => r.timings.duration < threshold,
    [`${name}: no server errors`]: (r) => r.status < 500
  });
}

export function contentCheck(response, expectedContent, checkName) {
  return check(response, {
    [`${checkName}: contains expected content`]: (r) => r.body.includes(expectedContent)
  });
}
