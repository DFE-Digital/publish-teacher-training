import http from 'k6/http';
import { group, sleep } from 'k6';
import { findPerformanceCheck, findContentCheck, findErrorHandler } from '../utils/checks.js';
import { buildFindSearchParams } from '../utils/helpers.js';
import { getRandomSubject, getRandomLocation } from '../data/subjects.js';

export function searchAndFilterJourney(environment, config) {
  group('Find: Search and Filter Journey', function() {

    group('Basic Search', function() {
      const basicSearchParams = buildFindSearchParams({
        subjects: [getRandomSubject()],
        location: getRandomLocation(),
        radius: 50
      });

      const response = http.get(`${environment.baseUrl}/results?${basicSearchParams}`);
      const isSuccess = findPerformanceCheck(response, 'Basic Search', config.expectedResponseTimes.search);

      findContentCheck(response, 'courses found', 'search-results');
      findContentCheck(response, 'Filters', 'filter-options');
      findContentCheck(response, 'Age group', 'course-listings');

      if (!isSuccess) {
        findErrorHandler(response, 'Basic Search');
      }

      sleep(2);
    });

    group('Multi-Filter Search', function() {
      const multiFilterParams = buildFindSearchParams({
        subjects: [getRandomSubject()],
        study_types: ['part_time'],
        location: getRandomLocation(),
        radius: 25,
        order: 'course_name_ascending',
        visa_sponsorship: true
      });

      const response = http.get(`${environment.baseUrl}/results?${multiFilterParams}`);
      const isSuccess = findPerformanceCheck(response, 'Multi-Filter Search', config.expectedResponseTimes.search);

      findContentCheck(response, 'Part time (18 to 24 months)', 'filter-validation');
      findContentCheck(response, 'courses found', 'filtered-results');

      if (!isSuccess) {
        findErrorHandler(response, 'Multi-Filter Search');
      }

      sleep(1);
    });

    group('Advanced Filter Search', function() {
      const advancedParams = buildFindSearchParams({
        subjects: [getRandomSubject()],
        qualifications: ['pgce', 'pgde'],
        funding_types: ['salary', 'bursary'],
        location: getRandomLocation(),
        radius: 10
      });

      const response = http.get(`${environment.baseUrl}/results?${advancedParams}`);
      const isSuccess = findPerformanceCheck(response, 'Advanced Filter Search', config.expectedResponseTimes.search);

      findContentCheck(response, 'PGCE', 'qualification-filter');
      findContentCheck(response, 'Salary', 'funding-filter');

      if (!isSuccess) {
        findErrorHandler(response, 'Advanced Filter Search');
      }

      sleep(1);
    });
  });
}
