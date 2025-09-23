import http from 'k6/http'
import { group, sleep } from 'k6'
import { findPerformanceCheck, findContentCheck, findErrorHandler } from '../utils/checks.js'
import { buildFindSearchParams } from '../utils/helpers.js'
import { getRandomSubject, getRandomLocation } from '../data/subjects.js'

export function searchAndFilterJourney (environment, config) {
  group('Find: Search and Filter Journey', function () {
    group('Basic Search', function () {
      const basicSearchParams = buildFindSearchParams({
        subjects: [getRandomSubject()],
        location: getRandomLocation(),
        radius: 50
      })

      const response = http.get(`${environment.baseUrl}/results?${basicSearchParams}`)
      const isSuccess = findPerformanceCheck(response, 'Basic Search', config.expectedResponseTimes.search)

      findContentCheck(response, 'search-results', 'courses found')
      findContentCheck(response, 'filter-options', 'Filters')
      findContentCheck(response, 'course-listings', 'Age group')

      if (!isSuccess) {
        findErrorHandler(response, 'Basic Search')
      }

      sleep(2)
    })

    group('Multi-Filter Search', function () {
      const multiFilterParams = buildFindSearchParams({
        subjects: [getRandomSubject()],
        study_types: ['part_time'],
        location: getRandomLocation(),
        radius: 25,
        order: 'course_name_ascending',
        visa_sponsorship: true
      })

      const response = http.get(`${environment.baseUrl}/results?${multiFilterParams}`)
      const isSuccess = findPerformanceCheck(response, 'Multi-Filter Search', config.expectedResponseTimes.search)

      findContentCheck(response, 'filter-validation', 'Part time (18 to 24 months)')
      findContentCheck(response, 'filtered-results', 'courses found')

      if (!isSuccess) {
        findErrorHandler(response, 'Multi-Filter Search')
      }

      sleep(1)
    })

    group('Advanced Filter Search', function () {
      const advancedParams = buildFindSearchParams({
        subjects: [getRandomSubject()],
        qualifications: ['pgce', 'pgde'],
        funding_types: ['salary', 'bursary'],
        location: getRandomLocation(),
        radius: 10
      })

      const response = http.get(`${environment.baseUrl}/results?${advancedParams}`)
      const isSuccess = findPerformanceCheck(response, 'Advanced Filter Search', config.expectedResponseTimes.search)

      findContentCheck(response, 'qualification-filter', 'PGCE')
      findContentCheck(response, 'funding-filter', 'Salary')

      if (!isSuccess) {
        findErrorHandler(response, 'Advanced Filter Search')
      }

      sleep(1)
    })
  })
}
