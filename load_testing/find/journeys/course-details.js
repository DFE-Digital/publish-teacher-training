import http from 'k6/http';
import { group, sleep } from 'k6';
import { findPerformanceCheck, findContentCheck, findErrorHandler } from '../utils/checks.js';
import { extractFindCourseLinks } from '../utils/helpers.js';

export function courseDetailsJourney(environment, config) {
  group('Find: Course Detail Journey', function() {

    group('Course Search to Detail', function() {
      const searchResponse = http.get(`${environment.baseUrl}/results?subjects[]=13`);
      const courseLinks = extractFindCourseLinks(searchResponse.body);

      if (courseLinks.length === 0) {
        console.error('No course links found in search results');
        return;
      }

      const randomCourseLink = courseLinks[Math.floor(Math.random() * Math.min(courseLinks.length, 3))];
      sleep(1);

      const courseResponse = http.get(`${environment.baseUrl}${randomCourseLink}`);
      const isSuccess = findPerformanceCheck(courseResponse, 'Course Detail Page', config.expectedResponseTimes.courseDetails);

      findContentCheck(courseResponse, 'Course information', 'course-info');
      findContentCheck(courseResponse, 'How to apply', 'apply-section');
      findContentCheck(courseResponse, 'Training provider', 'provider-info');

      if (!isSuccess) {
        findErrorHandler(courseResponse, 'Course Detail Page');
      }

      sleep(3);
    });

    group('Course Apply Journey', function() {
      const searchResponse = http.get(`${environment.baseUrl}/results?subjects[]=G1`);
      const courseLinks = extractFindCourseLinks(searchResponse.body);

      if (courseLinks.length > 0) {
        const courseLink = courseLinks[0];
        const courseResponse = http.get(`${environment.baseUrl}${courseLink}`);

        const hasApplyButton = courseResponse.body.includes('Apply for this course') ||
                              courseResponse.body.includes('Apply now');

        findContentCheck(courseResponse, 'Apply', 'apply-button');

        if (hasApplyButton) {
          const isSuccess = findPerformanceCheck(courseResponse, 'Apply Journey', config.expectedResponseTimes.courseDetails);

          if (!isSuccess) {
            findErrorHandler(courseResponse, 'Apply Journey');
          }
        }
      }

      sleep(2);
    });
  });
}
