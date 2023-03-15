# frozen_string_literal: true

module Support
  class RawCSVSchoolsForm < BaseForm
    FIELDS = %i[
      school_details
    ].freeze

    attr_accessor(*FIELDS)

    validates :school_details, presence: true

    alias compute_fields new_attributes
  end
end
