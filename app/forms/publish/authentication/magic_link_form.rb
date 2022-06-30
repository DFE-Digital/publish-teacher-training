module Publish
  module Authentication
    class MagicLinkForm
      include ActiveModel::Model

      attr_accessor :email

      validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

      def submit
        if valid?
          GenerateAndSendMagicLinkService.call(user:) if user.present?
          true
        else
          false
        end
      end

    private

      def user
        @user ||= User.find_by(email:)
      end
    end
  end
end
