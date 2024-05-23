# frozen_string_literal: true

module Publish
  class CourseLengthForm < BaseModelForm
    alias course_enrichment model

    FIELDS = %i[course_length course_length_other_length].freeze

    attr_accessor(*FIELDS)

    validates :course_length, presence: true

    private

    def compute_fields
      course_enrichment
        .attributes
        .symbolize_keys
        .slice(*FIELDS)
        .merge(formatted_params)
        .symbolize_keys
    end

    def formatted_params
      if custom_length_provided?
        new_attributes.merge(course_length: new_attributes[:course_length_other_length])
      else
        new_attributes
      end
    end

    def custom_length_provided?
      new_attributes[:course_length] == 'Other' && new_attributes[:course_length_other_length].present?
    end

    def fields_to_ignore_before_save
      [:course_length_other_length]
    end
  end
end
