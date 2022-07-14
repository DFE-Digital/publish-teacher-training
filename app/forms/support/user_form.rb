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

    # alias :user :model

    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :email, presence: true, format: { with: /\A.*@.*\z/, message: "Enter an email address in the correct format, like name@example.com" }
    validate :email_is_lowercase
    validate :email_is_unique

  private

    def compute_fields
      model.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
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
      # return if user.persisted? && user.email == email
      #
      # if email.present? && User.exists?(email:)
      #   errors.add(:email, "must be unique")
      # end
    end
  end
end
