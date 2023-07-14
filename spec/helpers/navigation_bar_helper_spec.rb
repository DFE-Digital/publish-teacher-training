# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NavigationBarHelper do
  describe '#navigation_items' do
    subject do
      helper.navigation_items(provider)
    end

    let(:accredited_provider_item) { subject.find { |item| item[:name] == 'Accredited providers' } }

    context 'when provider is an accredited provider' do
      let(:provider) { create(:provider, :accredited_provider) }

      it 'does not include accredited_provider in items' do
        expect(accredited_provider_item).to be_nil
      end
    end

    context 'when provider is not an accredited provider' do
      let(:provider) { create(:provider) }

      it 'includes accredited_provider in items' do
        expect(accredited_provider_item).not_to be_nil
      end

      it 'includes the correct link to accredited providers' do
        expect(accredited_provider_item[:url]).to eq publish_provider_recruitment_cycle_accredited_providers_path(provider.provider_code, provider.recruitment_cycle.year)
      end
    end
  end
end
