module Publish
  class CourseFundingForm < Form
    alias_method :course, :model

    FIELDS = %i[
      funding_type
    ].freeze

    attr_accessor(*FIELDS)

    # validates :funding_type, presence: true

    def initialize(model, params: {})
      super(model, model, params:)
    end

    def funding_type_updated?
      course.funding_type != compute_fields[:funding_type]
    end

    def is_fee_based?
      funding_type == "fee"
    end

  private

    # def assign_attributes_to_model
    #   model.funding_type = funding_type
    #   model.can_sponsor_student_visa = can_sponsor_student_visa
    # end

    def original_fields_values
      {
        funding_type: course.funding_type,
      }
    end

    def compute_fields
      original_fields_values.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def form_store_key
      :funding_types_and_visas
    end
  end
end
