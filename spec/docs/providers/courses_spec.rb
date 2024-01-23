# frozen_string_literal: true

require 'swagger_helper'

describe 'API', :with_publish_constraint do
  path '/recruitment_cycles/{year}/providers/{provider_code}/courses' do
    get 'Returns the courses for the specified provider.' do
      operationId :public_api_v1_provider_courses
      tags 'course'
      produces 'application/json'
      parameter name: :year,
                in: :path,
                type: :string,
                required: true,
                description: 'The starting year of the recruitment cycle. Also accepts "current" for the current recruitment cycle.',
                example: Settings.current_recruitment_cycle_year
      parameter name: :provider_code,
                in: :path,
                type: :string,
                required: true,
                description: 'The unique code of the provider.',
                example: 'T92'
      parameter name: :filter,
                in: :query,
                schema: { '$ref' => '#/components/schemas/CourseFilter' },
                type: :object,
                style: :deepObject,
                explode: true,
                required: false,
                description: 'Refine courses to return.',
                example: {
                  has_vacancies: true,
                  subjects: '00,01',
                  updated_since: '2020-11-13T11:21:55Z',
                  degree_grade: 'two_two',
                  can_sponsor_visa: true
                }
      parameter name: :sort,
                in: :query,
                schema: { '$ref' => '#/components/schemas/Sort' },
                type: :object,
                style: :form,
                explode: false,
                required: false,
                example: 'provider.provider_name,name',
                description: 'Field(s) to sort the courses by.'
      parameter name: :page,
                in: :query,
                schema: { '$ref' => '#/components/schemas/Pagination' },
                type: :object,
                style: :deepObject,
                explode: true,
                required: false,
                example: { page: 2, per_page: 10 },
                description: 'Pagination options to navigate through the collection.'
      parameter name: :include,
                in: :query,
                type: :string,
                required: false,
                description: 'The associated data for this resource.',
                schema: {
                  enum: %w[accredited_provider provider recruitment_cycle]
                },
                example: 'recruitment_cycle,provider'

      curl_example description: 'Get all courses for a provider',
                   command: 'curl -X GET https://api.publish-teacher-training-courses.service.gov.uk/api/public/v1/recruitment_cycles/2020/providers/B20/courses'

      curl_example description: 'Get the second page of courses for a provider',
                   command: 'curl -X GET https://api.publish-teacher-training-courses.service.gov.uk/api/public/v1/recruitment_cycles/2020/provideers/B20/courses?page[page]=2'

      response '200', 'The collection of courses.' do
        let(:provider) { create(:provider) }
        let(:year) { provider.recruitment_cycle.year }
        let(:provider_code) { provider.provider_code }
        let(:include) { 'provider' }

        before do
          create(:course, :engineers_teach_physics, provider:, course_code: 'C100')
          create(:course, :engineers_teach_physics, provider:, course_code: 'C101')
        end

        schema({ '$ref': '#/components/schemas/CourseListResponse' })

        run_test!
      end
    end
  end

  path '/recruitment_cycles/{year}/providers/{provider_code}/courses/{course_code}' do
    get 'Returns the specified course for the specified provider.' do
      operationId :public_api_v1_provider_course
      tags 'course'
      produces 'application/json'
      parameter name: :year,
                in: :path,
                type: :string,
                required: true,
                description: 'The starting year of the recruitment cycle. Also accepts "current" for the current recruitment cycle.',
                example: Settings.current_recruitment_cycle_year
      parameter name: :provider_code,
                in: :path,
                type: :string,
                required: true,
                description: 'The unique code of the provider.',
                example: 'T92'
      parameter name: :course_code,
                in: :path,
                type: :string,
                required: true,
                description: 'The code of the course.',
                example: 'X130'
      parameter name: :include,
                in: :query,
                type: :string,
                required: false,
                description: 'The associated data for this resource.',
                schema: {
                  enum: %w[accredited_provider provider recruitment_cycle]
                },
                example: 'recruitment_cycle,provider'

      curl_example description: 'Get a course for a provider',
                   command: 'curl -X GET https://api.publish-teacher-training-courses.service.gov.uk/api/public/v1/recruitment_cycles/2020/providers/B20/courses/2N22'

      response '200', 'The collection of courses offered by the specified provider.' do
        let(:provider) { create(:provider) }
        let(:course) { create(:course, :engineers_teach_physics, course_code: 'A123', provider:) }

        let(:year) { provider.recruitment_cycle.year }
        let(:provider_code) { provider.provider_code }
        let(:course_code) { course.course_code }
        let(:include) { 'provider' }

        schema({ '$ref': '#/components/schemas/CourseSingleResponse' })

        run_test!
      end
    end
  end
end
