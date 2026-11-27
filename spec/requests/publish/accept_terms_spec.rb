# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publish accept terms", type: :request do
  include DfESignInUserHelper

  let(:provider) { create(:provider) }
  let(:user) { create(:user, :inactive, providers: [provider]) }

  before { login_user(user) }

  it "returns to the requested publish page after accepting terms" do
    requested_path = delete_publish_provider_user_path(
      provider_code: provider.provider_code,
      id: create(:user, providers: [provider]).id,
      from: "index",
      return_to: "support",
      support_return: {
        recruitment_cycle_year: provider.recruitment_cycle_year,
        page: 2,
      },
    )

    get requested_path

    expect(response).to redirect_to(publish_accept_terms_path)

    patch publish_accept_terms_path, params: {
      publish_interruption_accept_terms_form: { terms_accepted: "1" },
    }

    expect(response).to redirect_to(requested_path)
    expect(user.reload.accepted_terms?).to be(true)
  end

  it "falls back to the publish root when terms are accepted without a stored path" do
    get publish_accept_terms_path

    patch publish_accept_terms_path, params: {
      publish_interruption_accept_terms_form: { terms_accepted: "1" },
    }

    expect(response).to redirect_to(publish_root_path)
    expect(user.reload.accepted_terms?).to be(true)
  end
end
