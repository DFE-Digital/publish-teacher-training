# frozen_string_literal: true

module Find
  module Courses
    module ResultsPageTitle
      class View < ViewComponent::Base
        def initialize(courses_count:, address:, search_form:)
          super

          @courses_count = courses_count
          @address = address
          @search_form = search_form
        end

        def content
          t(translation_key, **translation_params)
        end

      private

        def translation_key
          case [location_present?, subject_single?]
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
            subject: subject_name&.downcase,
            radius: radius_value,
          }
        end

        def location_present?
          @address.formatted_address.present?
        end

        def subject_single?
          subjects.count == 1 && subject_name.present?
        end

        def subject_name
          return unless subjects.count == 1

          @subject_name ||= Subject.find_by(subject_code: subjects.first)&.subject_name
        end

        def subjects
          @subjects ||= Array(@search_form.subjects).compact_blank
        end

        def distance_search?
          @address.distance_search?
        end

        def radius_value
          @search_form.radius
        end

        def formatted_count
          number_with_delimiter(@courses_count)
        end
      end
    end
  end
end
