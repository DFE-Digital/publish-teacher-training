export const peakSurgeScenario = {
  executor: 'ramping-vus',
  startVUs: 50,
  stages: [
    { duration: '1m', target: 500 }, // Quick ramp to moderate load
    { duration: '2m', target: 2000 }, // Build to high load
    { duration: '5m', target: 3000 }, // Peak Find opens load
    { duration: '5m', target: 3000 }, // Sustain peak (150 RPS target)
    { duration: '2m', target: 0 } // Ramp down
  ],
  gracefulRampDown: '30s',
  tags: {
    service: 'find',
    scenario: 'peak-surge',
    description: 'Find opens surge - 3000 concurrent users, 150 RPS'
  }
}
