# frozen_string_literal: true

class UserSession
  attr_reader :email, :sign_in_user_id
  attr_accessor :first_name, :last_name

  def initialize(email:, sign_in_user_id:, first_name:, last_name:, id_token: nil, provider: "dfe")
    @email = email&.downcase
    @sign_in_user_id = sign_in_user_id
    @first_name = first_name
    @last_name = last_name
    @id_token = id_token
    @provider = provider&.to_s
  end

  def self.begin_session!(session, omniauth_payload)
    session["user"] = {
      "email" => omniauth_payload["info"]["email"],
      "sign_in_user_id" => omniauth_payload["uid"],
      "first_name" => omniauth_payload["info"]["first_name"],
      "last_name" => omniauth_payload["info"]["last_name"],
      "last_active_at" => Time.zone.now,
      "id_token" => omniauth_payload["credentials"]["id_token"],
      "provider" => omniauth_payload["provider"],
    }
  end

  def self.load_from_session(session)
    user_session = session["user"]
    return unless user_session

    return if user_session.fetch("last_active_at") < 2.hours.ago

    user_session["last_active_at"] = Time.zone.now

    new(
      email: user_session["email"],
      sign_in_user_id: user_session["sign_in_user_id"],
      first_name: user_session["first_name"],
      last_name: user_session["last_name"],
      id_token: user_session["id_token"],
      provider: user_session["provider"],
    )
  end

  def self.end_session!(session)
    session.delete("user")
  end

  def logout_url
    if AuthenticationService.magic_link? || AuthenticationService.persona?
      "/sign-in"
    else
      dfe_logout_url
    end
  end

private

  def dfe_logout_url
    uri = URI("#{Settings.dfe_signin.issuer}/session/end")
    uri.query = {
      id_token_hint: @id_token,
      post_logout_redirect_uri: "#{Settings.base_url}/auth/dfe/signout",
    }.to_query
    uri.to_s
  end
end
