# frozen_string_literal: true

module Publish
  module Authentication
    class SessionsController < ApplicationController
      include Unauthenticated

      def sign_out
        if Publish::AuthenticationService.persona?
          redirect_to "/auth/developer/signout"
        else
          redirect_to "/auth/dfe/signout"
        end
      end

      def callback
        omniauth_payload = request.env["omniauth.auth"]
        user = find_or_update_user(omniauth_payload)

        if user
          start_user_session(user, id_token: omniauth_payload["credentials"]["id_token"])

          redirect_to after_sign_in_path
        else
          redirect_to user_not_found_path
        end
      end

      def destroy
        session.delete(:cycle_year)
        if current_user.present?
          id_token = Current.session&.id_token
          terminate_user_session
          redirect_to(logout_url(id_token), allow_other_host: true)
        else
          redirect_to publish_root_path
        end
      end

    private

      def find_or_update_user(omniauth_payload)
        if AuthenticationService.persona?
          find_persona_user(omniauth_payload)
        else
          find_or_create_authenticated_user(omniauth_payload)
        end
      end

      def find_persona_user(omniauth_payload)
        user = User.find_by(email: omniauth_payload["info"]["email"]&.downcase)
        return unless user

        UserSessions::Update.call(user:, omniauth_payload:)
        user
      end

      def find_or_create_authenticated_user(omniauth_payload)
        uid = omniauth_payload["uid"]
        provider = ::Authentication.provider_map(omniauth_payload["provider"])

        authentication = ::Authentication.find_by(subject_key: uid, provider:)

        if authentication
          user = authentication.authenticable
        else
          user = User.find_by(email: omniauth_payload["info"]["email"]&.downcase)
          return unless user

          user.authentications.create!(provider:, subject_key: uid)
        end

        UserSessions::Update.call(user:, omniauth_payload:)

        user
      end

      def logout_url(id_token)
        if AuthenticationService.magic_link? || AuthenticationService.persona?
          "/sign-in"
        else
          dfe_logout_url(id_token)
        end
      end

      def dfe_logout_url(id_token)
        uri = URI("#{Settings.dfe_signin.issuer}/session/end")
        uri.query = {
          id_token_hint: id_token,
          post_logout_redirect_uri: "#{Settings.base_url}/auth/dfe/signout",
        }.to_query
        uri.to_s
      end

      def after_sign_in_path
        saved_path = session.delete("post_dfe_sign_in_path")

        saved_path || publish_root_path
      end
    end
  end
end
