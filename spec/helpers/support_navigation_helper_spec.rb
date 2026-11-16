# frozen_string_literal: true

require "rails_helper"

RSpec.describe SupportNavigationHelper, type: :helper do
  describe "#support_primary_navigation_items" do
    let(:year) { Find::CycleTimetable.current_year }
    let(:items) { helper.support_primary_navigation_items }

    def item(text)
      items.find { |navigation_item| navigation_item[:text] == text }
    end

    it "treats nested provider pages as part of Providers" do
      expect(item("Providers")[:active_when]).to eq(support_recruitment_cycle_providers_path(year))
    end

    it "treats data exports as part of Users" do
      expect(item("Users")[:active_when]).to include(support_recruitment_cycle_data_exports_path(year))
    end

    it "hides API keys while the api_keys flag is inactive" do
      expect(item("API keys")).to be_nil
    end

    it "shows API keys after Users once the api_keys flag is active" do
      FeatureFlag.activate(:api_keys)

      expect(items.pluck(:text)).to eq(["Onboarding", "Providers", "Users", "API keys", "Settings"])
      expect(item("API keys")).to eq(text: "API keys", href: support_api_keys_path, active_when: support_api_keys_path)
    end

    it "treats settings pages that live outside /settings as part of Settings" do
      expect(item("Settings")[:active_when]).to include(
        support_feature_flags_path,
        support_recruitment_cycles_path,
        support_financial_incentives_path,
        support_banners_path,
        support_feedback_index_path,
        support_subjects_path,
      )
    end
  end
end
