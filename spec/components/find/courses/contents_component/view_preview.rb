# frozen_string_literal: true

module Find
  module Courses
    module ContentsComponent
      class ViewPreview < ViewComponent::Preview
        def default
          render Find::Courses::ContentsComponent::View.new(mock_course)
        end

        private

        def mock_course
          FakeCourse.new(provider: Provider.new(provider_code: 'DFE', website: 'wwww.awesomeprovider@aol.com', train_with_disability: 'foo'),
                         about_course: 'foo',
                         how_school_placements_work: 'bar',
                         placements_heading: 'School placements',
                         about_accrediting_provider: 'foo',
                         salaried: true,
                         interview_process: 'bar',
                         application_status_open: true)
        end

        class FakeCourse
          include ActiveModel::Model
          attr_accessor(:provider, :about_course, :how_school_placements_work, :placements_heading, :about_accrediting_provider, :salaried, :interview_process, :application_status_open)

          def has_bursary?
            has_bursary
          end

          def application_status_open?
            application_status_open
          end

          def salaried?
            salaried
          end
        end
      end
    end
  end
end
