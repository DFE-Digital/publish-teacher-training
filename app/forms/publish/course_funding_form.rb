module Publish
  class CourseFundingForm < Form
    alias_method :course, :model

    FIELDS = %i[
      funding_type
      can_sponsor_skilled_worker_visa
      can_sponsor_student_visa
    ].freeze

    attr_accessor(*FIELDS)

    # validates :funding_type, presence: true

    def initialize(model, params: {})
      super(model, model, params:)
      @funding_type_updated = course.funding_type != compute_fields[:funding_type]
      origin_step
    end

    def funding_type_updated?
      @funding_type_updated
    end

    def origin_step
      @origin_step ||= if funding_type_updated?
                         if [course.funding_type, new_attributes[:funding_type]].include?("apprenticeship")
                           :apprenticeship
                         else
                           :funding_type
                         end
                       end
    end

    def is_fee_based?
      funding_type == "fee"
    end

    def visa_type
      is_fee_based? ? :student : :skilled_worker
    end

    def student_visa?
      visa_type == :student
    end

    def applicable_fields
      ["can_sponsor_#{visa_type}_visa".to_sym]
    end

  private

    def original_fields_values
      {
        funding_type: course.funding_type,
        can_sponsor_skilled_worker_visa: course.can_sponsor_skilled_worker_visa,
        can_sponsor_student_visa: course.can_sponsor_student_visa,
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
