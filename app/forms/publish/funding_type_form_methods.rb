module Publish
  module FundingTypeFormMethods
    def other_course_length?
      course_length_is_other?(course_length)
    end

  private

    def compute_fields
      course_enrichment
        .attributes
        .symbolize_keys
        .slice(*declared_fields)
        .merge(new_attributes)
        .merge(**hydrate_other_course_length)
        .symbolize_keys
    end

    def hydrate_other_course_length
      return {} unless course_length_is_other?(course_enrichment[:course_length])

      {
        course_length: "Other",
        course_length_other_length: course_enrichment[:course_length],
      }
    end

    def fields_to_ignore_before_save
      [:course_length_other_length]
    end

    def course
      course_enrichment.course
    end

    def course_length_is_other?(value)
      value.presence && %w[OneYear TwoYears].exclude?(value)
    end
  end
end
