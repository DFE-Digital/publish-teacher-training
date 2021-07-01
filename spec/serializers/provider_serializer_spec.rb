require "rails_helper"

describe ProviderSerializer do
  let(:ucas_preferences) { build(:provider_ucas_preference, type_of_gt12: :coming_or_not) }
  let(:provider) { create :provider, ucas_preferences: ucas_preferences, changed_at: Time.zone.now + 60 }

  subject { serialize(provider) }

  it { is_expected.to include(institution_code: provider.provider_code) }
  it { is_expected.to include(institution_name: provider.provider_name) }
  it { is_expected.to include(address1: provider.address1) }
  it { is_expected.to include(address2: provider.address2) }
  it { is_expected.to include(address3: provider.address3) }
  it { is_expected.to include(address4: provider.address4) }
  it { is_expected.to include(postcode: provider.postcode) }
  it { is_expected.to include(region_code: "%02d" % provider.region_code_before_type_cast) }
  it { is_expected.to include(institution_type: provider.provider_type_before_type_cast) }
  it { is_expected.to include(accrediting_provider: provider.accrediting_provider_before_type_cast) }
  it { is_expected.to include(recruitment_cycle: provider.recruitment_cycle.year) }
  it { is_expected.to include(created_at: provider.created_at.iso8601) }
  it { is_expected.to include(changed_at: provider.changed_at.iso8601) }

  describe "type_of_gt12" do
    subject { serialize(provider)["type_of_gt12"] }

    it { is_expected.to eq provider.ucas_preferences.type_of_gt12_before_type_cast }
  end

  describe "campuses" do
    before do
      create_list(:site, 40, code: nil, provider: provider)
    end

    subject { serialize(provider)["campuses"] }

    its(:count) { is_expected.to eq(37) }
  end

  describe "utt_application_alerts" do
    subject { serialize(provider)["utt_application_alerts"] }

    it { is_expected.to eq provider.ucas_preferences.send_application_alerts_before_type_cast }
  end

  describe "application alert recipient" do
    context "if set" do
      let(:application_alert_recipient) do
        serialize(provider)["contacts"].find do |contact|
          contact[:type] == "application_alert_recipient"
        end
      end

      subject { application_alert_recipient }

      its([:name]) { is_expected.to eq provider.contact_name }
      its([:email]) { is_expected.to eq provider.ucas_preferences.application_alert_email }
      its([:telephone]) { is_expected.to eq provider.telephone }
    end

    context "if nil" do
      let(:ucas_preferences) { build :ucas_preferences, application_alert_email: nil }
      let(:provider) { create :provider, ucas_preferences: ucas_preferences }
      let(:contacts) do
        serialize(provider)["contacts"].map { |contact| contact[:type] }
      end

      subject { contacts }

      it { is_expected.to_not include "application_alert_recipient" }
    end
  end

  context "when UCAS preferences are missing" do
    before do
      provider.ucas_preferences.destroy
      provider.reload
    end
    # no need to test for the application alret recipient as it will not have
    # been instantiated into the contacts object due to being nil

    it "handles the missing data gracefully" do
      expect(subject["utt_application_alerts"]).to be_nil
      expect(subject["type_of_gt12"]).to be_nil
    end
  end

  describe "contacts" do
    describe "generate provider object returns the providers contacts" do
      let(:contact)  { create :contact }
      let(:provider) { create :provider, contacts: [contact] }

      subject { serialize(provider)["contacts"].first }

      its([:name]) { is_expected.to eq contact.name }
      its([:email]) { is_expected.to eq contact.email }
      its([:telephone]) { is_expected.to eq contact.telephone }
    end

    describe "admin contact" do
      context "exists on provider record and not in contacts table" do
        subject { serialize(provider)["contacts"].find { |c| c[:type] == "admin" } }

        its([:name]) { is_expected.to eq provider.contact_name }
        its([:email]) { is_expected.to eq provider.email }
        its([:telephone]) { is_expected.to eq provider.telephone }
      end

      context "exists in contacts table" do
        let(:contact)  { create :contact, type: "admin" }
        let(:provider) { create :provider, contacts: [contact] }

        subject { serialize(provider)["contacts"].find { |c| c[:type] == "admin" } }

        its([:name]) { is_expected.to eq contact.name }
        its([:email]) { is_expected.to eq contact.email }
        its([:telephone]) { is_expected.to eq contact.telephone }
      end
    end
  end
end
