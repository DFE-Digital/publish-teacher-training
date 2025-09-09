import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { performanceCheck } from '../../shared/utils/performance-checks.js';
import { extractFindCourseLinks } from '../utils/helpers.js';

export function courseDetailsJourney(environment, config) {
  group('Find Course Details Journey', function() {
    // First get search results to extract course links
    const searchResponse = http.get(`${environment.baseUrl}/results?subjects%5B%5D=G1`);
    const courseLinks = extractFindCourseLinks(searchResponse.body);

    if (courseLinks.length > 0) {
      // Select random course from results
      const randomCourse = courseLinks[Math.floor(Math.random() * Math.min(courseLinks.length, 5))];

      const courseResponse = http.get(`${environment.baseUrl}${randomCourse}`);
      performanceCheck(courseResponse, 'Find Course Detail Page', config.expectedResponseTimes.courseDetails);

      check(courseResponse, {
        'course page loads': (r) => r.status === 200,
        'has course summary': (r) => r.body.includes('Fee or salary') || r.body.includes('Course length'),
        'has entry requirements': (r) => r.body.includes('Degree required') || r.body.includes('GCSE'),
        'has provider info': (r) => r.body.includes('Training provider') || r.body.includes('Contact'),
        'has visa sponsorship info': (r) => r.body.includes('Visa sponsorship'),
        'has qualification info': (r) => r.body.includes('Qualification awarded')
      });

      sleep(3); // Users spend more time reading course details
    }
  });
}
