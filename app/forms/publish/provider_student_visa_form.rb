module Publish
  class ProviderStudentVisaForm < BaseProviderForm
    FIELDS = %i[
      can_sponsor_student_visa
    ].freeze

    attr_accessor(*FIELDS)

    validates :can_sponsor_student_visa, inclusion: { in: [true, false], message: "Select if candidates can get a sponsored Student visa" }

  private

    def compute_fields
      provider.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end
  end
end
