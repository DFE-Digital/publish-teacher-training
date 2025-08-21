# frozen_string_literal: true

module Publish
  module Fields
    class InterviewProcessForm < BaseModelForm
      alias_method :course_enrichment, :model

      FIELDS = %i[interview_process interview_location].freeze

      attr_accessor(*FIELDS)

      delegate :recruitment_cycle_year, :provider_code, :name, to: :course

      validates :interview_location, inclusion: { in: ["online", "in person", "both", nil] }
      validates :interview_process, words_count: { maximum: 200, message: :too_long }

      def save!
        if valid?
          assign_attributes_to_model
          course_enrichment.status = :draft if course_enrichment.rolled_over?
          course_enrichment.save!
        else
          false
        end
      end

    private

      def compute_fields
        course_enrichment.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
      end
    end
  end
end
