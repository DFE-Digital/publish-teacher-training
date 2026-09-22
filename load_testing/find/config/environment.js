const findEnvironments = {
  qa: {
    baseUrl: 'https://qa.find-teacher-training-courses.service.gov.uk',
    name: 'qa-find',
    service: 'find'
  },
  staging: {
    baseUrl: 'https://staging.find-teacher-training-courses.service.gov.uk',
    name: 'staging-find',
    service: 'find'
  },
  local: {
    baseUrl: 'http://find.localhost',
    name: 'local-find',
    service: 'find',
    // Find only answers on find.localhost, so k6 resolves that name to the
    // development server. This avoids a proxy and its TLS certificate.
    hosts: {
      'find.localhost': '127.0.0.1:3001'
    }
  }
}

export function getFindEnvironment () {
  const env = __ENV.ENVIRONMENT || 'staging'
  return findEnvironments[env] || findEnvironments.staging
}

export function getFindConfig () {
  return {
    service: 'Find Teacher Training',
    expectedResponseTimes: {
      homepage: 2000,
      search: 3000,
      courseDetails: 2000,
      pagination: 3000
    },
    thresholds: {
      http_req_duration: ['p(95)<3000'],
      http_req_failed: ['rate<0.01'],
      find_error_rate: ['rate<0.01'],
      // A single empty search is normal. A search that is nearly always empty
      // means the journey measures an empty page, which is not a load test.
      'find_empty_results{check_name:search-results}': ['rate<0.25'],
      'find_empty_results{check_name:filtered-results}': ['rate<0.25'],
      'find_empty_results{check_name:advanced-results}': ['rate<0.25']
    }
  }
}
