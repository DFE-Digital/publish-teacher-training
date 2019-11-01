# == Schema Information
#
# Table name: provider_ucas_preference
#
#  application_alert_email   :text
#  created_at                :datetime         not null
#  gt12_response_destination :text
#  id                        :bigint           not null, primary key
#  provider_id               :integer          not null
#  send_application_alerts   :text
#  type_of_gt12              :text
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_provider_ucas_preference_on_provider_id  (provider_id)
#

require "rails_helper"

describe ProviderUCASPreference, type: :model do
  it { should belong_to(:provider) }

  describe "type_of_gt12" do
    it "is an enum" do
      expect(subject)
        .to define_enum_for(:type_of_gt12)
              .backed_by_column_of_type(:text)
              .with_values(
                coming_or_not: "Coming or Not",
                coming_enrol: "Coming / Enrol",
                not_coming: "Not coming",
                no_response: "No response",
              )
              .with_prefix("type_of_gt12")
    end
  end

  describe "send_application_alerts" do
    it "is an enum" do
      expect(subject)
        .to define_enum_for(:send_application_alerts)
              .backed_by_column_of_type(:text)
              .with_values(
                all: "Yes, required",
                none: "No, not required",
                my_programmes: "Yes - only my programmes",
                accredited_programmes: "Yes - for accredited programmes only",
              )
              .with_prefix("send_application_alerts_for")
    end
  end

  describe "gt12_contact=" do
    let(:provider) { create(:provider, ucas_preferences: ucas_preferences) }
    let(:ucas_preferences) { build(:provider_ucas_preference) }
    let(:new_email_address) { "test@email.com" }

    before do
      provider.ucas_preferences.gt12_contact = new_email_address
    end

    it "updates the providers gt12_response_destination attribute" do
      expect(provider.ucas_preferences.gt12_response_destination).to eq new_email_address
    end
  end

  describe "application_alert_contact= (email)" do
    let(:provider) { create(:provider, ucas_preferences: ucas_preferences) }
    let(:old_application_alert_contact) { "old@example.org" }
    let(:ucas_preferences) { build(:provider_ucas_preference, application_alert_email: old_application_alert_contact) }
    let(:new_application_alert_contact) { "new@example.com" }

    it "updates the providers application_alert_email attribute" do
      expect { provider.ucas_preferences.application_alert_contact = new_application_alert_contact }
        .to change { provider.ucas_preferences.application_alert_email }
              .from(old_application_alert_contact)
              .to(new_application_alert_contact)
    end
  end

  describe "application_alert_contact= (url)" do
    let(:provider) { create(:provider, ucas_preferences: ucas_preferences) }
    let(:old_application_alert_contact) { "https://example.org/foo/bar" }
    let(:ucas_preferences) { build(:provider_ucas_preference, application_alert_email: old_application_alert_contact) }
    let(:new_application_alert_contact) { "http://example.com/" }

    it "updates the providers application_alert_email attribute" do
      expect { provider.ucas_preferences.application_alert_contact = new_application_alert_contact }
        .to change { provider.ucas_preferences.application_alert_email }
              .from(old_application_alert_contact)
              .to(new_application_alert_contact)
    end
  end
end
