export const stressTestScenario = {
  executor: 'ramping-vus',
  startVUs: 100,
  stages: [
    { duration: '2m', target: 1000 }, // Build up load
    { duration: '5m', target: 2000 }, // Increase to stress level
    { duration: '10m', target: 4000 }, // Maximum stress test
    { duration: '5m', target: 4000 }, // Sustain stress load
    { duration: '3m', target: 0 } // Gradual ramp down
  ],
  gracefulRampDown: '30s',
  tags: {
    service: 'find',
    scenario: 'stress',
    description: 'Find stress test - 4000+ concurrent users, breaking point'
  }
}
