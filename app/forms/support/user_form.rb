# frozen_string_literal: true

module Support
  class UserForm < Form
    FIELDS = %i[
      first_name
      last_name
      email
    ].freeze

    attr_accessor(*FIELDS)

    alias :user :model

    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :email, presence: true, format: { with: /\A.*@.*\z/, message: "must contain @" }
    validate :email_is_lowercase
    validate :email_is_unique

  private

    def compute_fields
      user.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def form_store_key
      :user
    end

    def email_is_lowercase
      if email.present? && email.downcase != email
        errors.add(:email, "must be lowercase")
      end
    end

    def email_is_unique
      if email.present? && User.exists?(email: email)
        errors.add(:email, "must be unique")
      end
    end
  end
end
