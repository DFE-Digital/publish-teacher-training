require 'rails_helper'

describe Providers::CopyToRecruitmentCycleService do
  describe '#execute' do
    let(:site)   { build :site }
    let(:course) { build :course }
    let(:ucas_preferences) { build(:ucas_preferences, type_of_gt12: :coming_or_not) }
    let(:contacts) {
      [
        build(:contact, :admin_type),
        build(:contact, :utt_type),
        build(:contact, :web_link_type),
        build(:contact, :finance_type),
        build(:contact, :fraud_type)
      ]
    }
    let(:provider) {
      create :provider,
             courses: [course],
             sites: [site],
             ucas_preferences: ucas_preferences,
             contacts: contacts
    }
    let(:recruitment_cycle) { find_or_create :recruitment_cycle }
    let(:new_recruitment_cycle) { create :recruitment_cycle, :next }
    let(:new_provider) do
      new_recruitment_cycle.reload.providers.find_by(
        provider_code: provider.provider_code
      )
    end
    let(:service) { described_class.new(provider: provider) }

    it 'makes a copy of the provider in the new recruitment cycle' do
      expect(
        new_recruitment_cycle.providers.find_by(
          provider_code: provider.provider_code
        )
      ).to be_nil

      service.execute(new_recruitment_cycle)

      expect(new_provider).not_to be_nil
      expect(new_provider).not_to eq provider
    end

    it 'leaves the existing provider alone' do
      service.execute(new_recruitment_cycle)

      expect(recruitment_cycle.reload.providers).to eq [provider]
    end

    context 'the provider already exists in the new recruitment cycle' do
      let(:new_provider) {
        build :provider, provider_code: provider.provider_code
      }
      let(:new_recruitment_cycle) {
        create :recruitment_cycle, :next,
               providers: [new_provider]
      }

      it 'does not make a copy of the provider' do
        expect { service.execute(new_recruitment_cycle) }
          .not_to(change { new_recruitment_cycle.reload.providers.count })
      end
    end

    it 'assigns the new provider to organisation' do
      service.execute(new_recruitment_cycle)

      expect(new_provider.organisation).to eq provider.organisation
    end

    it 'copies over the ucas_preferences' do
      service.execute(new_recruitment_cycle)

      compare_attrs = %w[
        type_of_gt12
        send_application_alerts
        application_alert_email
        gt12_response_destination
      ]
      expect(new_provider.ucas_preferences.attributes.slice(compare_attrs))
        .to eq provider.ucas_preferences.attributes.slice(compare_attrs)
    end

    it 'copies over the contacts' do
      service.execute(new_recruitment_cycle)

      compare_attrs = %w[name email telephone]
      expect(new_provider.contacts.map { |c| c.attributes.slice(compare_attrs) })
        .to eq(provider.contacts.map { |c| c.attributes.slice(compare_attrs) })
    end

    it 'copies over the sites' do
      allow(site).to receive(:copy_to_provider)

      service.execute(new_recruitment_cycle)

      expect(site).to have_received(:copy_to_provider).with(new_provider)
    end

    it 'copies over the courses' do
      service_spy = spy
      allow(Courses::CopyToProviderService).to receive(:new).with(course: course).and_return(service_spy)

      service.execute(new_recruitment_cycle)

      expect(service_spy).to have_received(:execute).with(new_provider)
    end

    it 'returns a hash of the counts of copied objects' do
      output = service.execute(new_recruitment_cycle)

      expect(output).to eq(providers: 1, sites: 1, courses: 1)
    end
  end
end
