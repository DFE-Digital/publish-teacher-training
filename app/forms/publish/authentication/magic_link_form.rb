module Publish
  module Authentication
    class MagicLinkForm
      include ActiveModel::Model

      attr_accessor :email

      validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
      validate :user_exists

      def submit
        if valid?
          GenerateAndSendMagicLinkService.call(user: user)
          true
        else
          false
        end
      end

    private

      def user
        @user ||= User.find_by(email: email)
      end

      def user_exists
        errors.add(:email, :does_not_exist) if user.nil?
      end
    end
  end
end
