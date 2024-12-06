# frozen_string_literal: true

require 'rails_helper'

RSpec.describe API::Public::V1::ProvidersController do
  describe '#index' do
    let(:recruitment_cycle) { find_or_create :recruitment_cycle }

    context "when the recruitment cycle doesn't exist" do
      it 'returns a not found response' do
        allow(RecruitmentCycle).to receive(:find_by).and_return(nil)
        allow(RecruitmentCycle).to receive(:current_recruitment_cycle!).and_raise(ActiveRecord::RecordNotFound)

        get :index, params: {
          recruitment_cycle_year: 2024
        }

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when there are no providers' do
      before do
        get :index, params: {
          recruitment_cycle_year: recruitment_cycle.year
        }
      end

      it 'returns empty array of data' do
        expect(json_response['data']).to eql([])
      end
    end

    context 'when there are providers' do
      let(:organisation) { create(:organisation) }
      let(:contact) { build(:contact) }

      let(:provider) do
        create(:provider,
               provider_code: '1AT',
               provider_name: 'First',
               organisations: [organisation],
               contacts: [contact],
               can_sponsor_skilled_worker_visa: false,
               can_sponsor_student_visa: false)
      end

      before do
        provider
      end

      context 'successful response' do
        context 'with current recruitment cycle specified' do
          before do
            get :index, params: {
              recruitment_cycle_year: recruitment_cycle.year
            }
          end

          it 'returns correct number of providers for the current cycle' do
            parsed_provider_id = json_response['data'][0]['id'].to_i
            expect(json_response['data'].size).to be(1)
            expect(parsed_provider_id).to eq(provider.id)
          end
        end

        context 'with next recruitment cycle specified' do
          let(:next_recruitment_cycle) { create(:recruitment_cycle, :next) }
          let(:next_provider) do
            create(:provider,
                   organisations: [organisation],
                   provider_code: provider.provider_code,
                   recruitment_cycle: next_recruitment_cycle)
          end

          before do
            next_provider
            get :index, params: {
              recruitment_cycle_year: next_recruitment_cycle.year
            }
          end

          it 'returns correct number of providers for the next recruitment cycle' do
            parsed_provider_id = json_response['data'][0]['id'].to_i
            expect(parsed_provider_id).to eq(next_provider.id)
          end
        end
      end

      context 'when "current" is specified as the recruitment cycle' do
        before do
          get :index, params: {
            recruitment_cycle_year: 'current',
            include: 'recruitment_cycle'
          }
        end

        it 'returns correct number of providers for the current cycle' do
          parsed_recruitment_cycle_id = json_response['data'][0].dig('relationships', 'recruitment_cycle', 'data', 'id').to_i
          parsed_provider_id = json_response['data'][0]['id'].to_i
          expect(parsed_recruitment_cycle_id).to eq(recruitment_cycle.id)
          expect(json_response['data'].size).to be(1)
          expect(parsed_provider_id).to eq(provider.id)
        end
      end

      context 'when a non-existent recruitment cycle is specified' do
        before do
          get :index, params: {
            recruitment_cycle_year: '1066',
            include: 'recruitment_cycle'
          }
        end

        it 'returns correct number of providers for the current cycle' do
          parsed_recruitment_cycle_id = json_response['data'][0].dig('relationships', 'recruitment_cycle', 'data', 'id').to_i
          parsed_provider_id = json_response['data'][0]['id'].to_i
          expect(parsed_recruitment_cycle_id).to eq(recruitment_cycle.id)
          expect(json_response['data'].size).to be(1)
          expect(parsed_provider_id).to eq(provider.id)
        end
      end

      context 'with pagination' do
        before do
          recruitment_cycle.providers << build_list(:provider, 2, organisations: [organisation], contacts: [contact])

          get :index, params: {
            recruitment_cycle_year: recruitment_cycle.year,
            **pagination
          }
        end

        let(:pagination) do
          {
            page:,
            per_page: 1
          }
        end

        context 'when requested page is valid' do
          let(:first_page) { 1 }
          let(:last_page) { 3 }

          let(:url_prefix) do
            "http://test.host/api/public/v1/recruitment_cycles/#{recruitment_cycle.year}/providers?page="
          end

          context 'page 1' do
            let(:page) { first_page }

            it 'returns links' do
              links = json_response['links']

              expect(links['first']).to eq "#{url_prefix}#{first_page}&per_page=1"
              expect(links['last']).to eq "#{url_prefix}#{last_page}&per_page=1"
              expect(links['prev']).to be_nil
              expect(links['next']).to eq "#{url_prefix}#{page + 1}&per_page=1"
            end
          end

          context 'page 2' do
            let(:page) { 2 }

            it 'returns links' do
              links = json_response['links']

              expect(links['first']).to eq "#{url_prefix}#{first_page}&per_page=1"
              expect(links['last']).to eq "#{url_prefix}#{last_page}&per_page=1"
              expect(links['prev']).to eq "#{url_prefix}#{page - 1}&per_page=1"
              expect(links['next']).to eq "#{url_prefix}#{page + 1}&per_page=1"
            end
          end

          context 'page 3' do
            let(:page) { last_page }

            it 'returns links' do
              links = json_response['links']

              expect(links['first']).to eq "#{url_prefix}#{first_page}&per_page=1"
              expect(links['last']).to eq "#{url_prefix}#{last_page}&per_page=1"
              expect(links['prev']).to eq "#{url_prefix}#{page - 1}&per_page=1"
              expect(links['next']).to be_nil
            end
          end
        end

        describe 'overflow' do
          context 'page 4' do
            let(:page) { 4 }

            it 'returns no links' do
              links = json_response['links']

              expect(links).to be_nil
            end

            it 'returns a bad request response' do
              expect(response).to have_http_status(:bad_request)
            end

            it 'returns a friendly error message' do
              expect(json_response['errors'][0]['detail']).to eql(I18n.t('pagy.overflow'))
            end
          end
        end
      end

      context 'with includes' do
        before do
          get :index, params: {
            recruitment_cycle_year: recruitment_cycle.year,
            include: 'recruitment_cycle'
          }
        end

        it 'returns the requested associated data in the response' do
          relationships = json_response['data'][0]['relationships']
          recruitment_cycle_id = relationships.dig('recruitment_cycle', 'data', 'id').to_i

          expect(json_response['data'][0]['relationships'].keys.sort).to eq(
            %w[recruitment_cycle]
          )

          expect(recruitment_cycle_id).to eq(provider.recruitment_cycle.id)
        end
      end

      context 'with sorting' do
        let(:provider2) do
          create(:provider,
                 provider_code: '0AT',
                 provider_name: 'Before',
                 organisations: [organisation],
                 contacts: [contact])
        end

        let(:provider3) do
          create(:provider,
                 provider_code: '2AT',
                 provider_name: 'Second',
                 organisations: [organisation],
                 contacts: [contact])
        end

        let(:provider_names_in_response) do
          json_response['data'].map do |provider|
            provider['attributes']['name']
          end
        end

        before do
          provider2
          provider3
        end

        context 'default ordering' do
          before do
            get :index, params: {
              recruitment_cycle_year: recruitment_cycle.year
            }
          end

          it 'returns them in a-z order' do
            expect(provider_names_in_response).to eq(%w[Before First Second])
          end
        end

        context 'passing in sort param' do
          before do
            get :index, params: {
              recruitment_cycle_year: recruitment_cycle.year,
              sort: sort_field
            }
          end

          context 'name' do
            let(:sort_field) { 'name' }

            it 'returns them in a-z order' do
              expect(provider_names_in_response).to eq(%w[Before First Second])
            end
          end

          context '-name' do
            let(:sort_field) { '-name' }

            it 'returns them in z-a order' do
              expect(provider_names_in_response).to eq(%w[Second First Before])
            end
          end

          context 'name,-name' do
            let(:sort_field) { 'name,-name' }

            it 'returns them in a-z order' do
              expect(provider_names_in_response).to eq(%w[Before First Second])
            end
          end

          context '-name,name' do
            let(:sort_field) { '-name,name' }

            it 'returns them in a-z order' do
              expect(provider_names_in_response).to eq(%w[Before First Second])
            end
          end
        end
      end

      context 'with sparse fields' do
        context 'when specific fields are specified' do
          before do
            get :index, params: {
              recruitment_cycle_year: recruitment_cycle.year,
              fields: {
                providers: 'name'
              }
            }
          end

          it 'returns only specified fields' do
            expect(json_response['data'].first['attributes'].keys.count).to eq(1)
            expect(json_response['data'].first).to have_attribute('name')
          end
        end

        context 'default fields' do
          let(:fields) do
            %w[ ukprn
                urn
                postcode
                provider_type
                region_code
                train_with_disability
                train_with_us
                website
                accredited_body
                changed_at
                city
                code
                county
                created_at
                name
                street_address_1
                street_address_2
                street_address_3
                latitude
                longitude
                telephone
                email
                can_sponsor_skilled_worker_visa
                can_sponsor_student_visa
                selectable_school]
          end

          before do
            get :index, params: {
              recruitment_cycle_year: recruitment_cycle.year
            }
          end

          it 'returns the default fields' do
            expect(json_response['data'].first['attributes'].keys).to match_array(fields)
          end
        end
      end

      context 'with filter' do
        let(:provider2) do
          Timecop.freeze(Time.zone.today + 1) do
            create(:accredited_provider,
                   :university,
                   provider_code: '2AT',
                   provider_name: 'Second',
                   organisations: [organisation],
                   contacts: [contact],
                   can_sponsor_skilled_worker_visa: true,
                   can_sponsor_student_visa: true,
                   region_code: :yorkshire_and_the_humber)
          end
        end

        let(:discarded_provider) do
          create(:provider,
                 provider_code: '3wc',
                 provider_name: 'Discarded',
                 discarded_at: 1.minute.ago,
                 organisations: [organisation],
                 contacts: [contact])
        end

        let(:provider_names_in_response) do
          json_response['data'].map do |provider|
            provider['attributes']['name']
          end
        end

        before do
          provider2
          discarded_provider

          get :index, params: {
            recruitment_cycle_year: recruitment_cycle.year,
            filter:
          }
        end

        context 'passing in updated_since param' do
          let(:filter) { { updated_since: (provider2.changed_at - 1.second).iso8601 } }

          it "returns 'Second' provider only" do
            expect(provider_names_in_response).to eq([provider2.provider_name])
          end
        end

        context 'passing in provider_name param' do
          let(:filter) { { provider_name: 'Sec' } }

          it "returns 'Second' provider only" do
            expect(provider_names_in_response).to eq([provider2.provider_name])
          end
        end

        context 'passing in provider_type param' do
          let(:filter) { { provider_type: 'university' } }

          it "returns 'Second' provider only" do
            expect(provider_names_in_response).to eq([provider2.provider_name])
          end
        end

        context 'passing in can_sponsor_skilled_worker_visa param' do
          let(:filter) { { can_sponsor_skilled_worker_visa: true } }

          it "returns 'Second' provider only" do
            expect(provider_names_in_response).to eq([provider2.provider_name])
          end
        end

        context 'passing in can_sponsor_student_visa param' do
          let(:filter) { { can_sponsor_student_visa: true } }

          it "returns 'Second' provider only" do
            expect(provider_names_in_response).to eq([provider2.provider_name])
          end
        end

        context 'passing in is_accredited_body param' do
          let(:filter) { { is_accredited_body: true } }

          it 'only returns the second provider' do
            expect(provider_names_in_response).to eq([provider2.provider_name])
          end
        end

        context 'passing in region_code param' do
          let(:filter) { { region_code: 'yorkshire_and_the_humber' } }

          it "returns 'Second' provider only" do
            expect(provider_names_in_response).to eq([provider2.provider_name])
          end
        end

        context 'passing in discarded param' do
          let(:filter) { { discarded: 'true' } }

          it "returns 'discarded' provider only" do
            expect(provider_names_in_response).to eq([discarded_provider.provider_name])
            expect(Time.zone.parse(response.parsed_body.dig('data', 0, 'attributes', 'discarded_at'))).to be_within(1.second).of(discarded_provider.discarded_at)
          end
        end

        context 'not passing in discarded param' do
          let(:filter) { {} }

          it 'returns provider attributes without discarded_at' do
            expect(response.parsed_body.dig('data', 0, 'attributes')).not_to have_attribute('discarded_at')
          end
        end
      end
    end

    context 'provider count' do
      before do
        create_list(:provider, 4)
        get :index, params: {
          recruitment_cycle_year: recruitment_cycle.year
        }
      end

      it 'returns the provider count in a meta object' do
        meta = json_response['meta']

        expect(meta['count']).to be(4)
      end
    end
  end

  describe '#show' do
    let(:provider) { create(:provider) }
    let(:recruitment_cycle_year) { provider.recruitment_cycle.year }
    let(:provider_code) { provider.provider_code }

    before do
      provider
    end

    context 'with unknown provider code' do
      let(:provider_code) { 'unknown' }
      let(:data) { nil }

      before do
        get :show, params: {
          recruitment_cycle_year:,
          code: provider_code
        }
      end

      it { expect(response).to have_http_status(:not_found) }

      it 'returns nil in the data attribute' do
        expect(json_response['data']).to be_nil
      end
    end

    context 'with correct provider code' do
      let(:expected_data) do
        {
          'id' => provider.id.to_s,
          'type' => 'providers',
          'attributes' => {
            'code' => provider.provider_code,
            'ukprn' => provider.ukprn,
            'urn' => provider.urn,
            'name' => provider.provider_name,
            'postcode' => provider.postcode,
            'provider_type' => provider.provider_type,
            'region_code' => provider.region_code,
            'train_with_disability' => provider.train_with_disability,
            'train_with_us' => provider.train_with_us,
            'website' => provider.website,
            'accredited_body' => provider.accredited_provider?,
            'changed_at' => provider.changed_at.iso8601,
            'city' => provider.town,
            'county' => provider.address4,
            'created_at' => provider.created_at.iso8601,
            'street_address_1' => provider.address1,
            'street_address_2' => provider.address2,
            'street_address_3' => provider.address3,
            'latitude' => provider.latitude,
            'longitude' => provider.longitude,
            'telephone' => provider.telephone,
            'email' => provider.email,
            'can_sponsor_student_visa' => provider.can_sponsor_student_visa,
            'can_sponsor_skilled_worker_visa' => provider.can_sponsor_skilled_worker_visa,
            'selectable_school' => provider.selectable_school
          }
        }
      end

      before do
        get :show, params: {
          recruitment_cycle_year:,
          code: provider_code
        }
      end

      it { expect(response).to have_http_status(:success) }

      it 'returns the correct attributes for the provider' do
        expect(json_response['data']).to include(expected_data)
      end

      context 'with lowercase provider code' do
        let(:provider_code) { provider.provider_code.downcase }

        it { expect(response).to have_http_status(:success) }

        it 'returns the correct attributes for the provider' do
          expect(json_response['data']).to include(expected_data)
        end
      end
    end
  end
end
