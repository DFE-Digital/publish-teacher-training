# == Schema Information
#
# Table name: provider
#
#  id                   :integer          not null, primary key
#  address4             :text
#  provider_name        :text
#  scheme_member        :text
#  contact_name         :text
#  year_code            :text
#  provider_code        :text
#  provider_type        :text
#  postcode             :text
#  scitt                :text
#  url                  :text
#  address1             :text
#  address2             :text
#  address3             :text
#  email                :text
#  telephone            :text
#  region_code          :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  accrediting_provider :text
#  last_published_at    :datetime
#  changed_at           :datetime         not null
#  opted_in             :boolean          default(FALSE)
#

require "rails_helper"

describe ProviderSerializer do
  let(:provider) { create :provider }

  subject { serialize(provider) }

  it { should include(institution_code: provider.provider_code) }
  it { should include(institution_name: provider.provider_name) }
  it { should include(address1: provider.enrichments.last.address1) }
  it { should include(address2: provider.enrichments.last.address2) }
  it { should include(address3: provider.enrichments.last.address3) }
  it { should include(address4: provider.enrichments.last.address4) }
  it { should include(postcode: provider.enrichments.last.postcode) }
  it { should include(institution_type: provider.provider_type) }
  it { should include(accrediting_provider: provider.accrediting_provider) }
  it { should include(contact_name: provider.contact_name) }
  it { should include(email: provider.enrichments.last.email) }
  it { should include(telephone: provider.enrichments.last.telephone) }

  describe 'ProviderSerializer#region_code' do
    subject do
      serialize(provider)["region_code"]
    end

    describe "provider region code 'London' can be overriden by enrichment region code 'Scotland'" do
      let(:enrichment) do
        build(:provider_enrichment, region_code: :scotland)
      end

      let(:provider) { create :provider, region_code: :london, enrichments: [enrichment] }
      it { is_expected.not_to eql("%02d" % 1) }
      it { is_expected.to eql("%02d" % 11) }
    end

    describe "provider region code 00 is overriden with enrichment region code" do
      let(:enrichment) do
        build(:provider_enrichment, region_code: region_code)
      end
      let(:region_code) { 1 }
      let(:provider) { create :provider, region_code: 0, enrichments: [enrichment] }
      it { is_expected.to eql("%02d" % region_code) }
      it { is_expected.not_to eql("%02d" % 0) }
    end
  end

  describe 'type_of_gt12' do
    subject { serialize(provider)['type_of_gt12'] }

    it { should eq provider.ucas_preferences.type_of_gt12_before_type_cast }
  end

  describe 'utt_application_alerts' do
    subject { serialize(provider)['utt_application_alerts'] }

    it { should eq provider.ucas_preferences.send_application_alerts_before_type_cast }
  end

  describe 'contacts' do
    describe 'generate provider object returns the providers contacts' do
      let(:contact)  { create :contact }
      let(:provider) { create :provider, contacts: [contact] }

      subject { serialize(provider)['contacts'].first }

      its([:name]) { should eq contact.name }
      its([:email]) { should eq contact.email }
      its([:telephone]) { should eq contact.telephone }
    end

    describe 'the application alert recipient has been serialized upon instantiation of the contact object' do
      subject { serialize(provider)['contacts'].find { |c| c[:type] == 'application_alert_recipient' } }

      its([:name]) { should eq '' }
      its([:email]) { should eq provider.ucas_preferences.application_alert_email }
      its([:telephone]) { should eq '' }
    end

    describe 'admin contact' do
      context 'exists on provider record and not in contacts table' do
        let(:provider) { create :provider }

        subject { serialize(provider)['contacts'].find { |c| c[:type] == 'admin' } }

        its([:name]) { should eq provider.contact_name }
        its([:email]) { should eq provider.email }
        its([:telephone]) { should eq provider.telephone }
      end

      context 'exists in contacts table' do
        let(:contact)  { create :contact, type: 'admin' }
        let(:provider) { create :provider, contacts: [contact] }

        subject { serialize(provider)['contacts'].find { |c| c[:type] == 'admin' } }

        its([:name]) { should eq contact.name }
        its([:email]) { should eq contact.email }
        its([:telephone]) { should eq contact.telephone }
      end
    end
  end
end
