import { check } from 'k6';
import { Trend, Rate } from 'k6/metrics';

const findResponseTimes = new Trend('find_response_time_trend');
const findErrors = new Rate('find_error_rate');

export function findPerformanceCheck(response, name, threshold = 3000) {
  findResponseTimes.add(response.timings.duration);

  const isSuccess = check(response, {
    [`${name}: status is 200`]: (r) => r.status === 200,
    [`${name}: response time < ${threshold}ms`]: (r) => r.timings.duration < threshold,
    [`${name}: no server errors`]: (r) => r.status < 500,
    [`${name}: not rate limited`]: (r) => r.status !== 429
  });

  if (!isSuccess) {
    findErrors.add(1);
  }

  return isSuccess;
}

export function findContentCheck(response, expectedContent, checkName) {
  return check(response, {
    [`Find ${checkName}: contains expected content`]: (r) => r.body.includes(expectedContent)
  });
}
