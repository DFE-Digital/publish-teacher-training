# frozen_string_literal: true

class DfESignInSession
  # Let's try calling this UserSession instead of DfESignInUser ?
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
    session["sign_in_session"] = {
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
    dfe_sign_in_session = session["sign_in_session"]
    return unless dfe_sign_in_session

    # Users who signed in before session expiry was implemented will not have
    # `last_active_at` set. In that case, force them to sign in again.
    return unless dfe_sign_in_session["last_active_at"]

    return if dfe_sign_in_session.fetch("last_active_at") < 2.hours.ago

    dfe_sign_in_session["last_active_at"] = Time.zone.now

    new(
      email: dfe_sign_in_session["email"],
      sign_in_user_id: dfe_sign_in_session["sign_in_user_id"],
      first_name: dfe_sign_in_session["first_name"],
      last_name: dfe_sign_in_session["last_name"],
      id_token: dfe_sign_in_session["id_token"],
      provider: dfe_sign_in_session["provider"],
    )
  end

  def self.end_session!(session)
    session.delete("sign_in_session")
  end

  def logout_url
    dfe_logout_url
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
