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

require 'rails_helper'

RSpec.describe Provider, type: :model do
  subject { create(:provider) }

  describe 'associations' do
    it { should have_many(:sites) }
    it { should have_many(:users).through(:organisations) }
  end

  describe 'changed_at' do
    it 'is set on create' do
      expect(subject.changed_at).to be_present
      expect(subject.changed_at).to eq subject.updated_at
    end

    it 'is set on update' do
      provider = create(:provider, updated_at: 1.hour.ago)
      provider.touch
      expect(subject.changed_at).to eq subject.updated_at
      expect(subject.changed_at).not_to be_within(1.second).of(1.hour.ago)
    end
  end

  describe '#address_info' do
    context 'empty enrichments' do
      it 'returns address of the provider' do
        provider = create(:provider, enrichments: [])

        expect(provider.address_info).to eq(
          'address1' => provider.address1,
          'address2' => provider.address2,
          'address3' => provider.address3,
          'address4' => provider.address4,
          'postcode' => provider.postcode,
          'region_code' => provider.region_code_before_type_cast
        )
      end

      context 'provider has enrichments' do
        context 'enrichment has nothing set for address_info' do
          context 'via absent json_data fields' do
            it 'returns address of the provider' do
              enrichment = build(:provider_enrichment)
              provider = create(:provider, enrichments: [enrichment])

              # forcing all fields to be absent in json_data altogether
              ProviderEnrichment.connection.update(<<~EOSQL)
                UPDATE provider_enrichment
                      SET json_data=json_data-'Address1'-'Address2'-'Address3'-'Address4'-'Postcode'-'RegionCode'
                      WHERE provider_code='#{enrichment.provider_code}'
              EOSQL

              expect(provider.address_info).to eq(
                'address1' => provider.address1,
                'address2' => provider.address2,
                'address3' => provider.address3,
                'address4' => provider.address4,
                'postcode' => provider.postcode,
                'region_code' => provider.region_code_before_type_cast
              )
            end
          end
          context 'via nil fields' do
            it 'returns address of the provider' do
              enrichment = build(:provider_enrichment,
                  address1: nil,
                  address2: nil,
                  address3: nil,
                  address4: nil,
                  postcode: nil,
                  region_code: nil)
              provider = create(:provider, enrichments: [enrichment])

              expect(provider.address_info).to eq(
                'address1' => provider.address1,
                'address2' => provider.address2,
                'address3' => provider.address3,
                'address4' => provider.address4,
                'postcode' => provider.postcode,
                'region_code' => provider.region_code_before_type_cast
              )
            end
          end
        end

        context 'enrichment is valid' do
          it 'returns json_data from the first enrichment' do
            enrichment = build(:provider_enrichment)
            provider = create(:provider, enrichments: [enrichment])

            expect(provider.address_info).to eq(
              'address1' => enrichment.address1,
              'address2' => enrichment.address2,
              'address3' => enrichment.address3,
              'address4' => enrichment.address4,
              'postcode' => enrichment.postcode,
              'region_code' => enrichment.region_code_before_type_cast
            )
          end

          it 'returns json_data from the newest enrichment' do
            enrichment = build(:provider_enrichment)
            newest_enrichment = build(:provider_enrichment, created_at: Date.today)
            provider = create(:provider, enrichments: [enrichment, newest_enrichment])

            expect(provider.address_info).to eq(
              'address1' => newest_enrichment.address1,
              'address2' => newest_enrichment.address2,
              'address3' => newest_enrichment.address3,
              'address4' => newest_enrichment.address4,
              'postcode' => newest_enrichment.postcode,
              'region_code' => newest_enrichment.region_code_before_type_cast
            )
          end
        end
        context 'enrichment has partial set for address_info' do
          it 'returns address of the enrichment' do
            enrichment = build(:provider_enrichment,
              address2: nil,
              address3: nil,
              address4: nil,
              postcode: nil)
            provider = create(:provider, enrichments: [enrichment])

            expect(provider.address_info).to eq(
              'address1' => enrichment.address1,
              'address2' => enrichment.address2,
              'address3' => enrichment.address3,
              'address4' => enrichment.address4,
              'postcode' => enrichment.postcode,
              'region_code' => enrichment.region_code_before_type_cast
            )
          end

          context 'enrichment has only region code set for address_info' do
            london = ProviderEnrichment.region_codes['London']
            no_region = ProviderEnrichment.region_codes['No region']
            context 'via absent json_data fields' do
              it 'returns address of the provider' do
                enrichment = build(:provider_enrichment, region_code: no_region,)
                provider = create(:provider, region_code: london, enrichments: [enrichment])

                # forcing all fields apart region_code to be absent in json_data altogether
                ProviderEnrichment.connection.update(<<~EOSQL)
                  UPDATE provider_enrichment
                        SET json_data=json_data-'Address1'-'Address2'-'Address3'-'Address4'-'Postcode'
                        WHERE provider_code='#{enrichment.provider_code}'
                EOSQL

                expect(provider.address_info).to eq(
                  'address1' => provider.address1,
                  'address2' => provider.address2,
                  'address3' => provider.address3,
                  'address4' => provider.address4,
                  'postcode' => provider.postcode,
                  'region_code' => provider.region_code_before_type_cast
                )
              end
            end
            context 'via nil fields' do
              it 'returns address of the provider' do
                enrichment = build(:provider_enrichment, region_code: no_region,
                address1: nil,
                address2: nil,
                address3: nil,
                address4: nil,
                postcode: nil)
                provider = create(:provider, region_code: london, enrichments: [enrichment])

                expect(provider.address_info).to eq(
                  'address1' => provider.address1,
                  'address2' => provider.address2,
                  'address3' => provider.address3,
                  'address4' => provider.address4,
                  'postcode' => provider.postcode,
                  'region_code' => provider.region_code_before_type_cast
                )
              end
            end
          end
        end
      end
    end
  end

  describe '#changed_since' do
    context 'with a provider that has been published after the given timestamp' do
      let(:provider) { create(:provider, last_published_at: 5.minutes.ago) }

      subject { Provider.changed_since(10.minutes.ago) }

      it { should include provider }
    end

    context 'with a provider that has been published exactly at the given timestamp' do
      let(:publish_time) { 10.minutes.ago }
      let(:provider) { create(:provider, last_published_at: publish_time) }

      subject { Provider.changed_since(publish_time) }

      it { should include provider }
    end

    context 'with a provider that has been published before the given timestamp' do
      let(:provider) { create(:provider, last_published_at: 1.hour.ago) }

      subject { Provider.changed_since(10.minutes.ago) }

      it { should_not include provider }
    end

    context 'with a provider that has never been published' do
      let(:provider) { create(:provider, last_published_at: nil) }

      describe 'with non-nil changed_since' do
        subject { Provider.changed_since(10.minutes.ago) }
        it { should_not include provider }
      end

      describe 'with changed_since set to nil' do
        subject { Provider.changed_since(nil) }
        it { should_not include provider }
      end
    end
  end

  describe '.opted_in' do
    let!(:opted_in_provider) { create(:provider, opted_in: true) }
    let!(:opted_out_provder) { create(:provider, opted_in: false) }

    it 'returns only the opted_in provider' do
      expect(Provider.opted_in).to match_array([opted_in_provider])
    end
  end

  describe '#updated_changed_at' do
    let(:provider) { create(:provider, changed_at: 1.hour.ago) }

    it 'sets changed_at to the current time' do
      Timecop.freeze do
        provider.update_changed_at
        expect(provider.changed_at).to eq Time.now.utc
      end
    end

    it 'sets changed_at to the given time' do
      timestamp = Time.now.utc
      provider.update_changed_at timestamp: timestamp
      expect(provider.changed_at).to eq timestamp
    end

    it 'leaves updated_at unchanged' do
      timestamp = 1.hour.ago
      provider.update updated_at: timestamp

      provider.update_changed_at
      expect(provider.updated_at).to eq timestamp
    end
  end
end
