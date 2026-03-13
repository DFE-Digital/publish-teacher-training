# frozen_string_literal: true

module Publish
  module Authentication
    module UserSessions
      class Update
        include ServicePattern

        attr_reader :user, :successful

        alias_method :successful?, :successful

        def initialize(user:, omniauth_payload:)
          @user = user

          attributes = {
            last_login_date_utc: Time.zone.now,
            email: omniauth_payload["info"]["email"]&.downcase,
          }

          attributes[:first_name] = omniauth_payload["info"]["first_name"] if omniauth_payload["info"]["first_name"].present?
          attributes[:last_name] = omniauth_payload["info"]["last_name"] if omniauth_payload["info"]["last_name"].present?

          @user.assign_attributes(attributes)
        end

        def call
          @successful = user.valid? && user.save!

          self
        end
      end
    end
  end
end
