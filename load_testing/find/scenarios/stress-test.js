export const stressTestScenario = {
  executor: 'ramping-vus',
  startVUs: 100,
  stages: [
    { duration: '2m', target: 200 }, // Build up load
    { duration: '5m', target: 300 }, // Increase to stress level
    { duration: '10m', target: 400 }, // Maximum stress test
    { duration: '5m', target: 400 }, // Sustain stress load
    { duration: '3m', target: 0 } // Gradual ramp down
  ],
  gracefulRampDown: '30s',
  tags: {
    service: 'find',
    scenario: 'stress',
    description: 'Find stress test - 4000+ concurrent users, breaking point'
  }
}
