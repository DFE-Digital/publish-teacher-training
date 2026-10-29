# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support user provider removal", travel: mid_cycle do
  include DfESignInUserHelper

  let(:recruitment_cycle) { find_or_create(:recruitment_cycle) }
  let(:other_cycle_provider) { create(:provider, recruitment_cycle: find_or_create(:recruitment_cycle, :previous)) }
  let(:user) { create(:user, providers: [other_cycle_provider]) }

  before do
    host! URI(Settings.base_url).host
    login_user(create(:user, :admin))
  end

  it "does not open the confirmation for a provider from another cycle" do
    get delete_provider_support_recruitment_cycle_user_path(
      recruitment_cycle.year,
      user,
      provider_id: other_cycle_provider.id,
    )

    expect(response).to have_http_status(:not_found)
    expect(user.reload.providers).to include(other_cycle_provider)
  end

  it "does not remove a provider from another cycle" do
    delete delete_provider_support_recruitment_cycle_user_path(
      recruitment_cycle.year,
      user,
      provider_id: other_cycle_provider.id,
    )

    expect(response).to have_http_status(:not_found)
    expect(user.reload.providers).to include(other_cycle_provider)
  end
end
