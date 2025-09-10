import { sleep, group } from 'k6'
import { getFindEnvironment, getFindConfig } from './config/environment.js'
import { homepageJourney } from './journeys/homepage.js'
import { searchAndFilterJourney } from './journeys/search-and-filter.js'
import { courseDetailsJourney } from './journeys/course-details.js'
import { paginationJourney } from './journeys/pagination.js'
import { baselineScenario } from './scenarios/baseline.js'
import { peakSurgeScenario } from './scenarios/peak-surge.js'
import { stressTestScenario } from './scenarios/stress-test.js'
import { quickTestScenario } from './scenarios/quick-test.js'

function getSelectedScenario () {
  const scenario = __ENV.SCENARIO || 'baseline'

  switch (scenario) {
    case 'baseline':
      return { find_baseline: baselineScenario }
    case 'peak-surge':
      return { find_peak_surge: peakSurgeScenario }
    case 'stress':
      return { find_stress: stressTestScenario }
    case 'quick':
      return { find_quick: quickTestScenario }
    default:
      return { find_baseline: baselineScenario }
  }
}

export const options = {
  scenarios: getSelectedScenario(),
  thresholds: getFindConfig().thresholds,
  cloud: {
    distribution: {
      distributionLabel1: { loadZone: 'amazon:gb:london', percent: 100 }
    }
  },
  tags: {
    service: 'find',
    testType: 'load'
  }
}

export function setup () {
  const environment = getFindEnvironment()
  const config = getFindConfig()
  console.log(`Testing ${config.service} - ${environment.name}: ${environment.baseUrl}`)
  return { environment, config }
}

export default function (data) {
  const { environment, config } = data

  // Find service specific user journey distribution based on historical data
  const journeyChoice = Math.random()

  group('Find Service User Journey', function () {
    if (journeyChoice < 0.51) {
      // 51% - Search operations (enhanced filtering patterns)
      searchAndFilterJourney(environment, config)
      paginationJourney(environment, config)
    } else if (journeyChoice < 0.93) {
      // 42% - Course page views (detailed browsing)
      courseDetailsJourney(environment, config)
    } else {
      // 7% - Apply button clicks (conversion actions - full journey)
      group('Full Find User Journey', function () {
        homepageJourney(environment, config)
        searchAndFilterJourney(environment, config)
        courseDetailsJourney(environment, config)
      })
    }
  })

  // Think time between actions (2-5 seconds)
  sleep(Math.random() * 3 + 2)
}

export function handleSummary (data) {
  return {
    'find-load-test-summary.json': JSON.stringify(data, null, 2)
  }
}
