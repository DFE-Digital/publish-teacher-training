# frozen_string_literal: true

require "rails_helper"

describe "Publish concurrent sign-in", service: :publish do
  include DfESignInUserHelper

  let(:provider) { create(:provider) }
  let!(:user) { create(:user, providers: [provider]) }

  before { host! URI(Settings.base_url).host }

  it "destroys any existing sessions for the user before creating the new one" do
    create(:session, sessionable: user, session_key: "old-browser-session-key")
    create(:session, sessionable: user, session_key: "another-device-session-key")

    expect {
      get "/auth/dfe/callback", headers: { "omniauth.auth" => user_exists_in_dfe_sign_in(user:) }
    }.to change { user.sessions.reload.count }.from(2).to(1)

    expect(user.sessions.pluck(:session_key)).not_to include(
      "old-browser-session-key",
      "another-device-session-key",
    )
  end
end
