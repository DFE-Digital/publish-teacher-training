# frozen_string_literal: true

require 'rails_helper'

describe 'GET v3/recruitment_cycle/:recruitment_cycle_year/providers', :with_publish_constraint do
  let(:recruitment_cycle) { find_or_create :recruitment_cycle }

  let!(:provider) do
    create(:provider,
      provider_code: '1AT',
      provider_name: 'First provider',
      contacts: [contact])
  end

  let(:contact) { build(:contact) }

  let(:json_response) { JSON.parse(response.body) }

  def perform_request
    get request_path
  end

  subject do
    perform_request

    response
  end

  describe 'JSON generated for a providers' do
    let(:request_path) { "/api/v3/recruitment_cycles/#{recruitment_cycle.year}/providers" }

    it { is_expected.to have_http_status(:success) }

    it 'has a data section with the correct attributes' do
      perform_request

      expect(json_response).to eq(
        'data' => [{
          'id' => provider.id.to_s,
          'type' => 'providers',
          'attributes' => {
            'provider_code' => provider.provider_code,
            'provider_name' => provider.provider_name,
            'recruitment_cycle_year' => provider.recruitment_cycle.year
          }
        }],
        'jsonapi' => {
          'version' => '1.0'
        }
      )
    end
  end

  context 'with unalphabetical ordering in the database' do
    let(:second_alphabetical_provider) do
      create(:provider, provider_name: 'Zork')
    end
    let(:provider_names_in_response) do
      JSON.parse(subject.body)['data'].map do |provider|
        provider['attributes']['provider_name']
      end
    end
    let(:request_path) { "/api/v3/recruitment_cycles/#{recruitment_cycle.year}/providers" }

    before do
      second_alphabetical_provider

      # This moves it last in the order that it gets fetched by default.
      provider.update(provider_name: 'Acme')
    end

    it 'returns them in alphabetical order' do
      expect(provider_names_in_response).to eq(%w[Acme Zork])
    end
  end

  context 'with two recruitment cycles' do
    let(:next_recruitment_cycle) { create(:recruitment_cycle, :next) }
    let(:next_provider) do
      create(:provider,
        provider_code: provider.provider_code,
        recruitment_cycle: next_recruitment_cycle)
    end

    describe 'making a request without specifying a recruitment cycle' do
      let(:request_path) { "/api/v3/recruitment_cycles/#{recruitment_cycle.year}/providers" }

      it 'only returns data for the current recruitment cycle' do
        next_provider

        perform_request

        expect(json_response['data'].count).to eq 1
        expect(json_response['data'].first)
          .to have_attribute('recruitment_cycle_year')
          .with_value(recruitment_cycle.year)
      end
    end

    describe 'making a request for the next recruitment cycle' do
      let(:request_path) do
        "/api/v3/recruitment_cycles/#{next_recruitment_cycle.year}/providers"
      end

      it 'only returns data for the next recruitment cycle' do
        next_provider

        perform_request

        expect(json_response['data'].count).to eq 1
        expect(json_response['data'].first)
          .to have_attribute('recruitment_cycle_year')
          .with_value(next_recruitment_cycle.year)
      end
    end
  end

  context 'Searching for a provider' do
    let(:base_provider_path) { "/api/v3/recruitment_cycles/#{recruitment_cycle.year}/providers" }
    let(:provider_two) do
      create(:provider,
        provider_code: '2AT',
        provider_name: 'Second provider',
        contacts: [contact])
    end

    before do
      provider_two
    end

    context 'Searching for a provider by its full name' do
      let(:request_path) { "#{base_provider_path}?search=Second provider" }

      it 'Only returns data for the provider' do
        perform_request

        expect(json_response['data'].count).to eq(1)
        expect(json_response['data'].first).to have_attribute('provider_code').with_value('2AT')
      end
    end

    context 'Searching for a provider by its lower case full name' do
      let(:request_path) { "#{base_provider_path}?search=second provider" }

      it 'Only returns data for the provider' do
        perform_request

        expect(json_response['data'].count).to eq(1)
        expect(json_response['data'].first).to have_attribute('provider_code').with_value('2AT')
      end
    end

    context 'Searching for a provider by part of its name' do
      let(:request_path) { "#{base_provider_path}?search=provider" }

      it 'Returns data for the matching providers' do
        perform_request

        expect(json_response['data'].count).to eq(2)
        expect(json_response['data'].first).to have_attribute('provider_code').with_value('1AT')
        expect(json_response['data'].last).to have_attribute('provider_code').with_value('2AT')
      end
    end

    context 'Searching for a provider by its provider code' do
      let(:request_path) { "#{base_provider_path}?search=2AT" }

      it 'Only returns data for the provider' do
        perform_request

        expect(json_response['data'].count).to eq(1)
        expect(json_response['data'].first).to have_attribute('provider_code').with_value('2AT')
      end
    end

    context 'Searching for a provider by a lower case provider code' do
      let(:request_path) { "#{base_provider_path}?search=2at" }

      it 'Only returns data for the provider' do
        perform_request

        expect(json_response['data'].count).to eq(1)
        expect(json_response['data'].first).to have_attribute('provider_code').with_value('2AT')
      end
    end

    context 'Searching for a provider with an invalid query' do
      context 'query is empty' do
        let(:request_path) { "#{base_provider_path}?search=" }

        it 'returns all providers' do
          perform_request

          expect(json_response['data'].count).to eq(2)
        end
      end

      context 'query is less than 2 characters' do
        let(:request_path) { "#{base_provider_path}?search=a" }

        it 'returns Bad Request' do
          perform_request

          expect(response).to have_http_status(:bad_request)
        end
      end
    end
  end

  context 'Sparse fields' do
    context 'Only returning specified fields' do
      let(:request_path) { "/api/v3/recruitment_cycles/#{recruitment_cycle.year}/providers?fields[providers]=provider_name,recruitment_cycle_year" }

      it 'Only returns the specified field' do
        perform_request

        expect(json_response['data'].first).to have_attribute('provider_name')
        expect(json_response['data'].first).to have_attribute('recruitment_cycle_year')
        expect(json_response['data'].first).not_to have_attribute('provider_code')
      end
    end

    context 'Default fields' do
      let(:request_path) { "/api/v3/recruitment_cycles/#{recruitment_cycle.year}/providers" }
      let(:data) { json_response['data'].first }

      before { perform_request }

      it 'Returns the provider name' do
        expect(data).to have_attribute('provider_name')
      end

      it 'Returns the provider code' do
        expect(data).to have_attribute('provider_code')
      end

      it 'Returns the recruitment cycle year' do
        expect(data).to have_attribute('recruitment_cycle_year')
      end
    end
  end
end
