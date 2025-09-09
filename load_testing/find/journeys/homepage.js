import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { performanceCheck } from '../../shared/utils/performance-checks.js';

export function homepageJourney(environment, config) {
  group('Find Homepage Journey', function() {
    const response = http.get(`${environment.baseUrl}/`);

    performanceCheck(response, 'Find Homepage Load', config.expectedResponseTimes.homepage);

    check(response, {
      'Find homepage loads successfully': (r) => r.status === 200,
      'contains course search form': (r) => r.body.includes('Find teacher training courses'),
      'has subject selection': (r) => r.body.includes('Subject'),
      'has location search': (r) => r.body.includes('City, town or postcode'),
      'has primary/secondary options': (r) => r.body.includes('Primary') && r.body.includes('Secondary')
    });

    sleep(1);
  });
}
