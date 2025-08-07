# frozen_string_literal: true

module Publish
  module Fields
    class WhatYouWillStudyForm < BaseModelForm
      include RecruitmentCycleHelper

      alias_method :course_enrichment, :model

      FIELDS = %i[theoretical_training_activities assessment_methods].freeze
      attr_accessor(*FIELDS)

      validates :theoretical_training_activities, presence: true, words_count: { maximum: 150 }
      validates :assessment_methods, words_count: { maximum: 50 }, allow_blank: true

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
