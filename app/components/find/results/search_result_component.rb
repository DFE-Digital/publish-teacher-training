module Find
  module Results
    class SearchResultComponent < ViewComponent::Base
      include ViewHelper

      attr_reader :course

      def initialize(course:, filtered_by_location: false, has_sites: false)
        super
        @course = course.decorate
        @filtered_by_location = filtered_by_location
        @has_sites = has_sites
      end

      def filtered_by_location?
        @filtered_by_location
      end

      def has_sites?
        @has_sites
      end

    private

      def show_visa_sponsorship_and_degree_required?
        course.show_visa_sponsorship?
      end

      def degree_required_status
        {
          two_one: "An undergraduate degree at class 2:1 or above, or equivalent.",
          two_two: "An undergraduate degree at class 2:2 or above, or equivalent.",
          third_class: "An undergraduate degree, or equivalent. This should be an honours degree (Third or above), or equivalent.",
          not_required: "An undergraduate degree, or equivalent.",
        }[course.degree_grade&.to_sym || "N/A"]
      end

      def visa_sponsorship_status
        if !course.salaried? && course.can_sponsor_student_visa
          "Student visas can be sponsored"
        elsif course.salaried? && course.can_sponsor_skilled_worker_visa
          "Skilled Worker visas can be sponsored"
        else
          "Visas cannot be sponsored"
        end
      end

      def accredited_body
        return nil if course.accrediting_provider.blank?

        "QTS ratified by #{helpers.smart_quotes(course.accrediting_provider.provider_name)}"
      end
    end
  end
end
