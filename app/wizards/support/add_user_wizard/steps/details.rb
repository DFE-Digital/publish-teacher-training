# frozen_string_literal: true

class Support::AddUserWizard
  module Steps
    class Details
      include DfE::Wizard::Step
      include ActiveModel::Validations::Callbacks

      attribute :first_name, :string
      attribute :last_name, :string
      attribute :email, :string
      attribute :admin, :boolean, default: false

      validates :first_name, presence: true
      validates :last_name, presence: true
      validates :email, presence: true, format: { with: /\A.*@.*\z/, message: "must contain @" }
      validate :email_is_unique
      validate :admin_email_domain, if: :admin

      before_validation :normalise_email

      def self.permitted_params
        %i[first_name last_name email admin]
      end

    private

      def normalise_email
        self.email = email.to_s.strip.downcase
      end

      def email_is_unique
        return if email.blank?
        return unless User.exists?(email:)

        errors.add(:email, :taken)
      end

      def admin_email_domain
        return if email.match?(/\A.*@(digital\.){0,1}education\.gov\.uk\z/)

        errors.add(:email, "must be an @[digital.]education.gov.uk domain")
      end
    end
  end
end
