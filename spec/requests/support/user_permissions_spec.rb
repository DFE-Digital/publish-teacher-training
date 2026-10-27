# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support::UserPermissionsController#destroy", travel: mid_cycle do
  include DfESignInUserHelper

  let(:provider) { create(:provider) }
  let(:user) { create(:user, providers: [provider]) }
  let(:user_permission) { user.user_permissions.find_by!(provider:) }

  before do
    host! URI(Settings.base_url).host
    login_user(create(:user, :admin))
  end

  it "removes the user permission for that provider" do
    delete support_user_permission_path(user_permission), params: {
      recruitment_cycle_year: provider.recruitment_cycle_year,
    }

    expect(response).to redirect_to(
      support_recruitment_cycle_user_providers_path(provider.recruitment_cycle_year, user),
    )
    expect(flash[:success]).to eq("#{user.full_name} has been removed from #{provider.provider_name}")
    expect(UserPermission.exists?(user_permission.id)).to be false
    expect(user.reload.providers).not_to include(provider)
  end

  it "does not remove a provider when the user permission cannot be found" do
    delete support_user_permission_path(0), params: {
      recruitment_cycle_year: provider.recruitment_cycle_year,
    }

    expect(response).to have_http_status(:not_found)
    expect(user.reload.providers).to include(provider)
  end
end
