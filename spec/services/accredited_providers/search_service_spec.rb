# frozen_string_literal: true

require 'rails_helper'

module AccreditedProviders
  describe SearchService do
    let(:accredited_provider) { create(:provider, :accredited_provider) }

    describe '#call' do
      it 'can search by ukprn' do
        expect(described_class.call(query: accredited_provider.ukprn).providers).to match([accredited_provider])
      end

      it 'can search by name' do
        expect(described_class.call(query: accredited_provider.provider_name).providers).to match([accredited_provider])
      end

      it 'can search by postcode' do
        expect(described_class.call(query: accredited_provider.postcode).providers).to match([accredited_provider])
      end

      context 'database has different providers' do
        before do
          create(:provider)
        end

        it 'only returns providers that are accredited' do
          expect(described_class.call.providers).to match([accredited_provider])
        end
      end

      context 'too many results' do
        before { create_list(:provider, 2, :accredited_provider) }

        it 'supports truncation' do
          expect(described_class.call(limit: 1).providers.size).to eq(1)
        end
      end

      context 'search order' do
        let!(:provider_one) { create(:provider, :accredited_provider, provider_name: 'Acorn Park School', postcode: 'NW1 8TY') }
        let!(:provider_two) { create(:provider, :accredited_provider, provider_name: 'Beaumont Parking School', postcode: 'NW1 9YU') }
        let!(:provider_three) { create(:provider, :accredited_provider, provider_name: 'Parking School', postcode: 'NW1 5WS') }

        it 'orders the results alphabetically' do
          expect(described_class.call.providers).to eq([provider_one, provider_two, provider_three])
        end

        context 'with a search query' do
          it 'orders the results alphabetically' do
            expect(described_class.call(query: 'NW1').providers).to eq([provider_one, provider_two, provider_three])
          end
        end
      end

      context 'with special characters' do
        let!(:provider_one) { create(:provider, :accredited_provider, provider_name: 'St Marys the Mount School') }
        let!(:provider_two) { create(:provider, :accredited_provider, provider_name: "St Mary's Kilburn") }
        let!(:provider_three) { create(:provider, :accredited_provider, provider_name: 'Beaumont College - A Salutem/Ambito College') }

        it 'matches all' do
          expect(described_class.call(query: "mary's").providers).to contain_exactly(provider_one, provider_two)
        end

        it 'matches all without punctuations' do
          expect(described_class.call(query: 'marys').providers).to contain_exactly(provider_one, provider_two)
        end

        it 'ignores non-punctuation characters' do
          expect(described_class.call(query: 'Salutem Ambito').providers).to eq([provider_three])
        end
      end

      context 'limit' do
        it 'can set a limit for the returned results' do
          expect(described_class.call(query: accredited_provider.ukprn, limit: 10).limit).to eq(10)
        end
      end
    end
  end
end
