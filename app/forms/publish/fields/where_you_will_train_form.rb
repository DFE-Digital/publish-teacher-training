# frozen_string_literal: true

module Publish
  module Fields
    class WhereYouWillTrainForm < BaseModelForm
      include RecruitmentCycleHelper

      alias_method :course_enrichment, :model

      FIELDS = %i[placement_selection_criteria duration_per_school theoretical_training_location theoretical_training_duration].freeze

      attr_accessor(*FIELDS)

      validates :placement_selection_criteria, words_count: { maximum: 50, message: :too_many_words }
      validates :placement_selection_criteria, presence: true

      validates :duration_per_school, words_count: { maximum: 50, message: :too_many_words }
      validates :duration_per_school, presence: true

      validates :theoretical_training_location, words_count: { maximum: 50, message: :too_many_words }

      validates :theoretical_training_duration, words_count: { maximum: 50, message: :too_many_words }

    private

      def declared_fields
        FIELDS
      end

      def compute_fields
        course_enrichment
          .attributes
          .symbolize_keys
          .slice(*FIELDS)
          .merge(new_attributes)
          .symbolize_keys
      end
    end
  end
end
