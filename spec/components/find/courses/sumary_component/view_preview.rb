# frozen_string_literal: true

module Find
  module Courses
    module SummaryComponent
      class ViewPreview < ViewComponent::Preview
        def with_bare_minimum
          course = Course.new(course_code: "FIND",
                              provider: Provider.new(provider_code: "DFE")).decorate
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
          accrediting_provider = Provider.new(provider_name: "University of BAT", accredited: true, provider_type: "university")
          FakeCourse.new(provider: Provider.new(provider_code: "DFE", website: "wwww.awesomeprovider@aol.com"),
                         accrediting_provider:,
                         course_code: "code",
                         has_bursary: false,
                         age_range_in_years: "11_to_18",
                         course_length: "OneYear",
                         applications_open_from: Time.zone.now,
                         start_date: Time.zone.now,
                         qualification: "pgce",
                         funding: "salaried",
                         subjects: nil,
                         level: :secondary)
        end

        def mock_primary_course
          accrediting_provider = Provider.new(provider_name: "University of BAT", accredited: true, provider_type: "university")
          FakeCourse.new(provider: Provider.new(provider_code: "DFE", website: "wwww.awesomeprovider@aol.com"),
                         accrediting_provider:,
                         course_code: "code",
                         has_bursary: false,
                         age_range_in_years: "3_to_7",
                         course_length: "OneYear",
                         applications_open_from: Time.zone.now,
                         start_date: Time.zone.now,
                         qualification: "pgce",
                         funding: "salaried",
                         subjects: nil,
                         level: :primary,
                         can_sponsor_student_visa: true)
        end

        class FakeCourse
          include ActiveModel::Model
          attr_accessor(:provider, :accrediting_provider, :course_code, :has_bursary, :age_range_in_years, :course_length, :applications_open_from, :start_date, :qualification, :funding, :subjects, :level, :can_sponsor_student_visa, :fee_uk_eu, :fee_international)

          delegate :provider_name, :provider_code, to: :provider, allow_nil: true

          def has_bursary?
            has_bursary
          end

          def fee?
            true
          end

          def enrichment_attribute(params)
            send(params)
          end

          def secondary_course?
            level.to_sym == :secondary
          end

          def study_mode
            "full_time"
          end

          def has_unpublished_changes?
            false
          end

          def is_published?
            false
          end
        end
      end
    end
  end
end
