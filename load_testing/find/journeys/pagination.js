import http from 'k6/http'
import { sleep, group } from 'k6'
import { findPerformanceCheck, findResultCount, findErrorHandler } from '../utils/checks.js'

export function paginationJourney (environment, config) {
  group('Find Pagination Journey', function () {
    const maxPages = 10

    for (let page = 1; page <= maxPages; page++) {
      const response = http.get(`${environment.baseUrl}/results?page=${page}`)

      const isSuccess = findPerformanceCheck(
        response,
        `Find Pagination Page ${page}`,
        config.expectedResponseTimes.pagination
      )

      findResultCount(response, 'Pagination')

      if (!isSuccess) {
        findErrorHandler(response, `Find Pagination Page ${page}`)
      }

      sleep(1)
    }
  })
}
