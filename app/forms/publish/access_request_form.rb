module Publish
  class AccessRequestForm < BaseModelForm
    alias_method :access_request, :model

    validates :first_name, :last_name, :email_address,
      :organisation, :reason,
      presence: true

    FIELDS = %i[
      first_name
      last_name
      email_address
      organisation
      reason
    ].freeze

    attr_accessor(*FIELDS, :user)

    def initialize(user:, params: {})
      @user = user
      super(AccessRequest.new, params:)
    end

  private

    def requester_email
      @requester_email ||= user.email
    end

    def assign_attributes_to_model
      access_request.assign_attributes(fields.except(*fields_to_ignore_before_save).merge(requester_email:))
      access_request.add_additional_attributes(requester_email)
    end

    def compute_fields
      access_request.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end
  end
end
