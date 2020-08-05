module API
  module Public
    module V1
      class CourseSearchService
        attr_reader :base_scope, :filter, :sort

        def initialize(base_scope:, filter:, sort:)
          @base_scope = base_scope
          @filter = filter
          @sort = sort
        end

        def call
          scope = base_scope
          scope = scope.with_vacancies if has_vacancies?
          scope = scope.with_funding_types(funding) if funding.any?
          scope = scope.with_study_modes(study_types) if study_types.any?
          scope = scope.with_qualifications(qualifications) if qualifications.any?
          scope = scope.with_subjects(subjects) if subjects.any?
          scope = scope.with_send if send_courses?
          scope = scope.order(order)
          scope
        end

      private

        def order
          if sort.empty?
            default_order
          else
            order_string
          end
        end

        def order_string
          sort.map { |string|
            string.starts_with?("-") ? "#{string[1..-1]} DESC" : "#{string} ASC"
          }.join(",")
        end

        def default_order
          "name"
        end

        def has_vacancies?
          filter[:has_vacancies].to_s.downcase == "true"
        end

        def funding
          return [] if filter[:funding].blank?

          filter[:funding].split(",")
        end

        def qualifications
          return [] if filter[:qualification].blank?

          filter[:qualification].split(",")
        end

        def study_types
          return [] if filter[:study_type].blank?

          filter[:study_type].split(",")
        end

        def subjects
          return [] if filter[:subjects].blank?

          filter[:subjects].split(",")
        end

        def send_courses?
          filter[:send_courses].to_s.downcase == "true"
        end
      end
    end
  end
end
