import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { performanceCheck } from '../../shared/utils/performance-checks.js';
import { getRandomSubject, getRandomLocation } from '../data/subjects.js';
import { buildFindSearchParams } from '../utils/helpers.js';

export function searchAndFilterJourney(environment, config) {
  group('Find Search and Filter Journey', function() {
    // Basic search with single criteria
    const basicSearchParams = buildFindSearchParams({
      subjects: [getRandomSubject()],
      location: getRandomLocation(),
      radius: 50
    });

    let response = http.get(`${environment.baseUrl}/results?${basicSearchParams}`);
    performanceCheck(response, 'Find Basic Search Results', config.expectedResponseTimes.search);

    check(response, {
      'search results load': (r) => r.status === 200,
      'shows course count': (r) => r.body.includes('courses found'),
      'has filter options': (r) => r.body.includes('Filters'),
      'has course listings': (r) => r.body.includes('Age group') || r.body.includes('Fee or salary')
    });

    sleep(2);

    // Apply multiple filters - Find service specific
    const multiFilterParams = buildFindSearchParams({
      subjects: [getRandomSubject()],
      study_types: ['part_time'],
      location: getRandomLocation(),
      radius: 25,
      order: 'course_name_ascending',
      visa_sponsorship: true
    });

    response = http.get(`${environment.baseUrl}/results?${multiFilterParams}`);
    performanceCheck(response, 'Find Multi-filter Search', config.expectedResponseTimes.search);

    check(response, {
      'filtered results load': (r) => r.status === 200,
      'results are filtered': (r) => r.body.includes('part time') || r.body.includes('part-time'),
      'filter state maintained': (r) => r.body.includes('Mathematics') || r.body.includes('courses found')
    });

    sleep(1);
  });
}
