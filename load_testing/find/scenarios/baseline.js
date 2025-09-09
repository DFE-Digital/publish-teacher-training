export const baselineScenario = {
  executor: 'ramping-vus',
  startVUs: 10,
  stages: [
    { duration: '2m', target: 50 },   // Ramp up to normal load
    { duration: '10m', target: 250 }, // Steady normal operations (Find service)
    { duration: '2m', target: 0 }     // Ramp down
  ],
  gracefulRampDown: '30s',
  tags: {
    service: 'find',
    scenario: 'baseline',
    description: 'Normal operations - 250 concurrent users'
  }
};
