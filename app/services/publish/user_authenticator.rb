# frozen_string_literal: true

module Publish
  class UserAuthenticator
    attr_reader :oauth

    def initialize(oauth:)
      @oauth = oauth
    end

    # 1. Find existing User via provider authentication
    # 2. Update User details if they have changed
    # 3. Fall back to email lookup for first-time sign-in and create authentication record
    # @return User or nil
    def call
      if authentication.present?
        sign_in!
      else
        first_sign_in!
      end
    end

  private

    def sign_in!
      authentication.authenticable.tap do |user|
        update_user_details(user)
      end
    end

    def first_sign_in!
      user = User.find_by(email: email_address)
      return unless user

      ::Authentication.transaction do
        user.authentications.create!(provider:, subject_key: oauth.uid)
        update_user_details(user)
      end
      user
    end

    def update_user_details(user)
      attributes = { last_login_date_utc: Time.zone.now }
      attributes[:email] = email_address unless user.email.casecmp?(email_address)
      attributes[:first_name] = oauth.info.first_name if oauth.info.first_name.present?
      attributes[:last_name] = oauth.info.last_name if oauth.info.last_name.present?

      user.update!(attributes)
    end

    def authentication
      @authentication ||= ::Authentication.find_by(subject_key: oauth.uid, provider:)
    end

    def provider
      ::Authentication.provider_map(oauth.provider)
    end

    def email_address
      oauth.info.email&.downcase
    end
  end
end
