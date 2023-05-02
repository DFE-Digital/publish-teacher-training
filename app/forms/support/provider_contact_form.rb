# frozen_string_literal: true

module Support
  class ProviderContactForm < BaseForm
    FIELDS = %i[
      email
      telephone
      website

      address1
      address2
      address3
      town
      address4
      postcode
    ].freeze

    validates :email, presence: true, email_address: true
    validates :telephone, phone: true
    validates :website, presence: true, url: true
    validates :address1, :town, presence: true
    validates :postcode, presence: true, postcode: true

    attr_accessor(*FIELDS)

    alias compute_fields new_attributes
  end
end
