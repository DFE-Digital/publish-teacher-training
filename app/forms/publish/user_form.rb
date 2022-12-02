# frozen_string_literal: true

module Publish
  class UserForm < Form
    FIELDS = %i[
      first_name
      last_name
      email
      id
      code
      authenticity_token
    ].freeze

    attr_accessor(*FIELDS)

    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :email, presence: true, format: { with: /\A.*@.*\z/, message: "Enter an email address in the correct format, like name@example.com" }
    validate :email_is_lowercase

    def provider_code_or_code(params)
      params[:code] || params[:provider_code]
    end

    def compute_fields
      model.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def fields_to_ignore_before_save
      %i[authenticity_token code]
    end

    def email_is_lowercase
      if email.present? && email.downcase != email
        errors.add(:email, I18n.t("activemodel.errors.models.publish/user_form.attributes.email.lowercase"))
      end
    end
  end
end
