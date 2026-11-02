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

      validate :user_is_valid

      before_validation :normalise_email

      def self.permitted_params
        %i[first_name last_name email admin]
      end

    private

      def normalise_email
        self.email = email.to_s.strip.downcase
      end

      def user_is_valid
        user = User.new(first_name:, last_name:, email:, admin:)
        return if user.valid?

        errors.merge!(user.errors)
      end
    end
  end
end
