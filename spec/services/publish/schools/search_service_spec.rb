# frozen_string_literal: true

require 'rails_helper'

module Publish
  module Schools
    describe SearchService do
      let(:school) { create(:gias_school) }

      describe '#call' do
        it 'can search by urn' do
          expect(described_class.call(query: school.urn).schools).to match([school])
        end

        it 'can search by name' do
          expect(described_class.call(query: school.name).schools).to match([school])
        end

        it 'can search by town' do
          expect(described_class.call(query: school.town).schools).to match([school])
        end

        it 'can search by postcode' do
          expect(described_class.call(query: school.postcode).schools).to match([school])
        end

        context 'database has open and closed schools' do
          let(:open_school) { create(:gias_school) }

          before do
            create(:gias_school, :closed)
          end

          it 'only returns schools that are open' do
            expect(described_class.call.schools).to match([open_school])
          end
        end

        context 'too many results' do
          before { create_list(:gias_school, 2, name: school.name) }

          it 'supports truncation' do
            expect(described_class.call(limit: 1).schools.size).to eq(1)
          end
        end

        context 'search order' do
          let!(:school_one) { create(:gias_school, name: 'Acorn Park School, London') }
          let!(:school_two) { create(:gias_school, name: 'Beaumont Parking School', town: 'London') }
          let!(:school_three) { create(:gias_school, name: 'Parking School, London') }

          it 'orders the results alphabetically' do
            expect(described_class.call.schools).to eq([school_one, school_two, school_three])
          end

          context 'with a search query' do
            it 'orders the results alphabetically' do
              expect(described_class.call(query: 'London').schools).to eq([school_one, school_two, school_three])
            end
          end
        end

        context 'with special characters' do
          let!(:school_one) { create(:gias_school, name: 'St Marys the Mount School') }
          let!(:school_two) { create(:gias_school, name: "St Mary's Kilburn") }
          let!(:school_three) { create(:gias_school, name: 'Beaumont College - A Salutem/Ambito College') }

          it 'matches all' do
            expect(described_class.call(query: "mary's").schools).to contain_exactly(school_one, school_two)
          end

          it 'matches all without punctuations' do
            expect(described_class.call(query: 'marys').schools).to contain_exactly(school_one, school_two)
          end

          it 'ignores non-punctuation characters' do
            expect(described_class.call(query: 'Salutem Ambito').schools).to eq([school_three])
          end
        end

        context 'limit' do
          it 'can set a limit for the returned results' do
            expect(described_class.call(query: school.urn, limit: 10).limit).to eq(10)
          end
        end
      end
    end
  end
end
