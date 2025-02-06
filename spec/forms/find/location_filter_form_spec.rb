# frozen_string_literal: true

require 'rails_helper'

module Find
  describe LocationFilterForm, type: :model do
    subject { described_class.new(params) }

    describe 'large_area' do
      let(:params) { { lq: 'Cornwall', l: '1' } }

      it 'merges a default radius of 50 when user searches a large area' do
        stub_request(:get, 'https://maps.googleapis.com/maps/api/geocode/json?address=Cornwall&components=country:UK&key=replace_me&language=en&sensor=false')
          .to_return(status: 200, headers: {}, body: file_fixture('google/geocode/cornwall.json').read)

        subject.valid?

        expect(subject.params).to eq(
          { lq: 'Cornwall',
            l: '1',
            latitude: 50.5036299,
            longitude: -4.6524982,
            loc: 'Cornwall, UK',
            c: 'England',
            radius: 50 }
        )
      end
    end

    describe 'non large_area' do
      let(:params) { { lq: 'London', l: '1' } }

      it 'does not merge a radius for searches on small areas' do
        stub_request(:get, 'https://maps.googleapis.com/maps/api/geocode/json?address=London&components=country:UK&key=replace_me&language=en&sensor=false')
          .to_return(status: 200, headers: {}, body: file_fixture('google/geocode/london.json').read)

        subject.valid?

        expect(subject.params).to eq(
          {
            lq: 'London',
            l: '1',
            latitude: 51.5072178,
            longitude: -0.1275862,
            loc: 'London, UK',
            c: 'England'
          }
        )
      end
    end

    describe 'validations' do
      before { subject.valid? }

      context 'no option selected' do
        let(:params) { { l: nil } }

        it 'validates selected options' do
          expect(subject.errors).to include('Select find courses by location or by training provider')
        end
      end

      context 'location is by_city_town_postcode' do
        context 'query is blank' do
          let(:params) do
            {
              l: '1',
              lq: ''
            }
          end

          it 'validates find_courses' do
            expect(subject.errors).to include('Enter a city, town or postcode')
          end
        end
      end

      context 'location is by_school_uni_or_provider' do
        context 'query is blank' do
          let(:params) do
            {
              l: '3',
              'provider.provider_name' => ''
            }
          end

          it 'validates find_courses' do
            expect(subject.errors).to include('Enter a provider name or code')
          end
        end
      end
    end
  end
end
