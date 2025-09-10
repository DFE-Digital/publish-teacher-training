const findEnvironments = {
  staging: {
    baseUrl: 'https://staging.find-teacher-training-courses.service.gov.uk',
    name: 'staging-find',
    service: 'find'
  },
  local: {
    baseUrl: 'https://find.localhost',
    name: 'local-find',
    service: 'find'
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
      find_errors: ['rate<0.01']
    },
    cloudOptions: {
      distribution: {
        distributionLabel1: { loadZone: 'amazon:gb:london', percent: 100 }
      },
      projectID: __ENV.GRAFANA_PROJECT_ID || null,
      name: 'Find Teacher Training Load Test'
    }
  }
}
