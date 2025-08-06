# frozen_string_literal: true

# Provider service namespace
module Publish
  # Module for managing courses
  module Courses
    # Module for managing fields related to school placements in courses
    module Fields
      # Form object for managing school placement fields in course enrichment
      class SchoolPlacementForm < BaseModelForm
        include RecruitmentCycleHelper
        include FundingTypeFormMethods

        alias_method :course_enrichment, :model
        delegate :version, to: :course_enrichment

        FIELDS = %i[placement_school_activities support_and_mentorship].freeze

        attr_accessor(*FIELDS)

        validates :placement_school_activities, presence: true
        validates :placement_school_activities, words_count: { maximum: 150 }
        validates :support_and_mentorship, words_count: { maximum: 50 }

        private

        # Returns the fields that are declared for this form
        def declared_fields
          FIELDS
        end
      end
    end
  end
end