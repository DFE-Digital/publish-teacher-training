# frozen_string_literal: true

require 'rails_helper'

module Find
  describe ProviderHelper do
    describe '#provider_autocomplete_options' do
      subject { provider_autocomplete_options(providers) }

      let(:providers) { build_list(:provider, 3) }
      let(:providers_ordered_by_name) { providers.sort_by(&:provider_name) }
      let(:expected_provider_options) do
        providers_ordered_by_name.map do |provider|
          ["#{provider.provider_name} (#{provider.provider_code})", provider.provider_name, {
            'data-synonyms' => provider.synonyms.join('|'),
            'data-boost' => 1.5
          }]
        end
      end

      it 'returns nil for the first item in the array' do
        expect(subject[0]).to eql([nil, nil, nil])
      end

      it 'returns the providers in the correct order' do
        expect(subject[1]).to eql(expected_provider_options[0])
        expect(subject[2]).to eql(expected_provider_options[1])
        expect(subject[3]).to eql(expected_provider_options[2])
      end
    end
  end
end
