# frozen_string_literal: true

module Support
  class UserForm < Form
    FIELDS = %i[
      first_name
      last_name
      email
      id
    ].freeze

    attr_accessor(*FIELDS)

    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :email, presence: true, format: { with: /\A.*@.*\z/, message: "Enter an email address in the correct format, like name@example.com" }
    validate :email_is_lowercase

  private

    def compute_fields
      model.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def form_store_key
      :user
    end

    def email_is_lowercase
      if email.present? && email.downcase != email
        errors.add(:email, I18n.t("activemodel.errors.models.support/user_form.attributes.email.lowercase"))
      end
    end
  end
end
