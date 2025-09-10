import http from 'k6/http';
import { group, sleep } from 'k6';
import { findPerformanceCheck, findContentCheck, findErrorHandler } from '../utils/checks.js';

export function homepageJourney(environment, config) {
  group('Find: Homepage Journey', function() {
    group('Homepage Load', function() {
      const response = http.get(`${environment.baseUrl}/`);
      const isSuccess = findPerformanceCheck(response, 'Homepage', config.expectedResponseTimes.homepage);

      findContentCheck(response, 'Find teacher training courses', 'main-heading');
      findContentCheck(response, 'Search', 'search-button');

      if (!isSuccess) {
        findErrorHandler(response, 'Homepage');
      }

      sleep(2);
    });
  });
}
