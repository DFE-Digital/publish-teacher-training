export const quickTestScenario = {
  executor: 'ramping-vus',
  startVUs: 1,
  stages: [
    { duration: '5s', target: 10 },
    { duration: '15s', target: 10 },
    { duration: '5s', target: 0 }
  ],
  gracefulRampDown: '5s',
  tags: {
    service: 'find',
    scenario: 'quick',
    description: 'Super quick test - 10 users, 25 seconds'
  }
}
