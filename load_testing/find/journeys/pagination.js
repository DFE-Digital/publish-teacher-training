import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { performanceCheck } from '../../shared/utils/performance-checks.js';

export function paginationJourney(environment, config) {
  group('Find Pagination Journey', function() {
    // Test pagination through multiple pages (up to 69 pages available)
    const maxPages = Math.min(5, Math.floor(Math.random() * 10) + 1);

    for (let page = 1; page <= maxPages; page++) {
      const response = http.get(`${environment.baseUrl}/results?page=${page}`);
      performanceCheck(response, `Find Pagination Page ${page}`, config.expectedResponseTimes.pagination);

      check(response, {
        [`page ${page} loads successfully`]: (r) => r.status === 200,
        [`page ${page} has results`]: (r) => r.body.includes('courses found'),
        [`page ${page} has course listings`]: (r) => r.body.includes('Fee or salary') || r.body.includes('Age group')
      });

      sleep(1);
    }
  });
}
