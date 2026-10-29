# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support::FeatureFlagsController" do
  include DfESignInUserHelper

  before do
    host! URI(Settings.base_url).host
    login_user(create(:user, :admin))
  end

  it "turns a feature on and off and shows when it last changed" do
    freeze_time

    get support_feature_flags_path
    expect(response.body).to include("This flag has not been updated")

    put activate_support_feature_flag_path(:bursaries_and_scholarships_announced)

    expect(FeatureFlagState.find_by(name: "bursaries_and_scholarships_announced").active).to be(true)
    expect(JSON.parse(RedisClient.current.get("feature_flags_bursaries_and_scholarships_announced"))["state"]).to be(true)

    get support_feature_flags_path
    expect(response.body).to include("at #{Time.zone.now.to_fs(:govuk_date_and_time)}")

    put deactivate_support_feature_flag_path(:bursaries_and_scholarships_announced)

    expect(FeatureFlagState.find_by(name: "bursaries_and_scholarships_announced").active).to be(false)
    expect(JSON.parse(RedisClient.current.get("feature_flags_bursaries_and_scholarships_announced"))["state"]).to be(false)
  end

  it "rejects an unknown feature without storing it" do
    put activate_support_feature_flag_path(:not_a_feature)

    expect(response).to redirect_to(support_feature_flags_path)
    expect(FeatureFlagState.count).to eq(0)
  end
end
