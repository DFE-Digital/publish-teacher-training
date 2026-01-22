module Find
  module Courses
    module ResultsPageTitle
      class View < ViewComponent::Base
        attr_reader :subjects, :radius

        def initialize(courses_count:, address:, subjects:, radius:)
          super

          @courses_count = courses_count
          @address = address
          @subjects = Array(subjects).compact_blank
          @radius = radius
        end

        def content
          t(translation_key, **translation_params)
        end

      private

        def translation_key
          case [location_present?, subject_name.present?]
          in [false, false]
            ".page_title_without_location"
          in [false, true]
            ".page_title_with_subject"
          in [true, false]
            distance_search? ? ".page_title_with_distance" : ".page_title_with_location"
          in [true, true]
            distance_search? ? ".page_title_with_subject_and_distance" : ".page_title_with_subject_and_location"
          end
        end

        def translation_params
          {
            count: @courses_count,
            formatted_count:,
            location: @address.short_address,
            subject: subject_name,
            radius:,
          }
        end

        def location_present?
          @address.formatted_address.present?
        end

        def subject_name
          return unless @subjects.count == 1

          @subject ||= Subject.find_by(subject_code: subjects.first)

          return unless @subject

          if @subject.language_subject?
            @subject.subject_name
          else
            @subject.subject_name.downcase
          end
        end

        def distance_search?
          @address.distance_search?
        end

        def formatted_count
          number_with_delimiter(@courses_count)
        end
      end
    end
  end
end
