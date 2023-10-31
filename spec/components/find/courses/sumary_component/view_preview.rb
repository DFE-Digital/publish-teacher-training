# frozen_string_literal: true

module Find
  module Courses
    module SummaryComponent
      class ViewPreview < ViewComponent::Preview
        def with_bare_minimum
          course = Course.new(course_code: 'FIND',
                              provider: Provider.new(provider_code: 'DFE')).decorate
          render Find::Courses::SummaryComponent::View.new(course)
        end

        def primary_course_with_all_columns
          course = CourseDecorator.new(mock_primary_course)

          render Find::Courses::SummaryComponent::View.new(course)
        end

        def secondary_course_with_all_columns
          course = CourseDecorator.new(mock_secondary_course)

          render Find::Courses::SummaryComponent::View.new(course)
        end

        private

        def mock_secondary_course
          accrediting_provider = Provider.new(provider_name: 'University of BAT', accrediting_provider: 'accredited_provider', provider_type: 'university')
          FakeCourse.new(provider: Provider.new(provider_code: 'DFE', website: 'wwww.awesomeprovider@aol.com'),
                         accrediting_provider:,
                         has_bursary: false,
                         age_range_in_years: '11_to_18',
                         course_length: 'OneYear',
                         applications_open_from: Time.zone.now,
                         start_date: Time.zone.now,
                         qualification: 'pgce',
                         funding_type: 'salaried',
                         subjects: nil,
                         level: :secondary)
        end

        def mock_primary_course
          accrediting_provider = Provider.new(provider_name: 'University of BAT', accrediting_provider: 'accredited_provider', provider_type: 'university')
          FakeCourse.new(provider: Provider.new(provider_code: 'DFE', website: 'wwww.awesomeprovider@aol.com'),
                         accrediting_provider:,
                         has_bursary: false,
                         age_range_in_years: '3_to_7',
                         course_length: 'OneYear',
                         applications_open_from: Time.zone.now,
                         start_date: Time.zone.now,
                         qualification: 'pgce',
                         funding_type: 'salaried',
                         subjects: nil,
                         level: :primary,
                         can_sponsor_student_visa: true)
        end

        class FakeCourse
          include ActiveModel::Model
          attr_accessor(:provider, :accrediting_provider, :has_bursary, :age_range_in_years, :course_length, :applications_open_from, :start_date, :qualification, :funding_type, :subjects, :level, :can_sponsor_student_visa)

          def has_bursary?
            has_bursary
          end

          def enrichment_attribute(params)
            send(params)
          end

          def secondary_course?
            level.to_sym == :secondary
          end

          def study_mode
            'full_time'
          end
        end
      end
    end
  end
end
