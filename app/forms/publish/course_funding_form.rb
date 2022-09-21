module Publish
  class CourseFundingForm < Form
    FIELDS = %i[
      funding_type
    ].freeze

    attr_accessor(*FIELDS)

    # validates :funding_type, presence: true

    def initialize(model, params: {})
      super(model, model, params:)
    end

  private

    # def assign_attributes_to_model
    #   model.funding_type = funding_type
    #   model.can_sponsor_student_visa = can_sponsor_student_visa
    # end

    # TODO: something is wrong here. The model doesn't have a funding type as a attribute.
    def compute_fields
      model.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def form_store_key
      :funding_types_and_visas
    end
  end
end
