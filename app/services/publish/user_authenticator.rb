# frozen_string_literal: true

module Publish
  class UserAuthenticator
    attr_reader :oauth

    def initialize(oauth:)
      @oauth = oauth
    end

    # @return User or nil
    def call
      user = User.find_by(email: email_address)
      return unless user

      update_user_details(user)
      user
    end

  private

    def update_user_details(user)
      attributes = { last_login_date_utc: Time.zone.now }
      attributes[:first_name] = oauth.info.first_name if oauth.info.first_name.present?
      attributes[:last_name] = oauth.info.last_name if oauth.info.last_name.present?

      user.update!(attributes)
    end

    def provider
      ::Authentication.provider_map(oauth.provider)
    end

    def email_address
      oauth.info.email&.downcase
    end
  end
end
