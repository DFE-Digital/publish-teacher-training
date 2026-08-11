# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support provider school checks" do
  include DfESignInUserHelper

  let(:provider) { create(:provider) }
  let(:recruitment_cycle) { provider.recruitment_cycle }
  let(:gias_school) { create(:gias_school) }
  let(:admin) { create(:user, :admin) }

  before do
    host! URI(Settings.base_url).host
    login_user(admin)
  end

  it "rolls back the legacy Site when Provider::School creation fails" do
    allow(ProviderSchools::Creator).to receive(:call).and_raise(StandardError, "provider school failed")

    expect {
      expect {
        put support_recruitment_cycle_provider_schools_check_path(
          recruitment_cycle.year,
          provider,
          school_id: gias_school.id,
        )
      }.to raise_error(StandardError, "provider school failed")
    }.not_to(change { provider.reload.sites.count })
  end
end
