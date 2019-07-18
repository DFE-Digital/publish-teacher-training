require 'mcb_helper'
require 'stringio'

describe 'mcb providers sync_to_find' do
  def sync_to_find(*arguments)
    stderr = nil
    output = with_stubbed_stdout(stdin: "", stderr: stderr) do
      $mcb.run %W[provider sync_to_find] + arguments
    end
    { stdout: output, stderr: stderr }
  end

  let(:email) { 'user@education.gov.uk' }
  let(:recruitment_year1) { find_or_create(:recruitment_cycle, year: '2020') }
  let(:recruitment_year2) { RecruitmentCycle.current_recruitment_cycle }

  let(:provider) { create :provider, recruitment_cycle: recruitment_year1 }
  let(:rolled_over_provider) do
    new_provider = provider.dup
    new_provider.update(recruitment_cycle: recruitment_year2)
    new_provider.update(organisations: provider.organisations)
    new_provider.save
    new_provider
  end

  def stub_manage_api_request(provider_code)
    stub_request(:post, "#{Settings.manage_api.base_url}/api/Publish/internal/courses/#{provider_code}")
      .with { |req| req.body == { "email": email }.to_json }
      .to_return(
        status: 200,
        body: '{ "result": true }'
      )
  end

  before do
    allow(MCB).to receive(:config).and_return(email: email)
  end

  context 'when an authorised user syncs an existing provider' do
    let!(:requester) { create(:user, email: email, organisations: rolled_over_provider.organisations) }

    context 'with an unspecified recruitment cycle' do
      it 'calls Manage API successfully with the provider from the default recruitment cycle' do
        manage_api_request = stub_manage_api_request(rolled_over_provider.provider_code)
        expect { sync_to_find(rolled_over_provider.provider_code) }.to_not raise_error
        expect(manage_api_request).to have_been_made
      end
    end

    #Currently no way to specify recruitment year for publish as this is still in C# land
    xcontext 'with a specified recruitment cycle' do
      it 'calls Manage API successfully with the provider' do
        manage_api_request = stub_manage_api_request(provider.provider_code)
        expect { sync_to_find(provider.provider_code, '-r', recruitment_year1.year) }.to_not raise_error
        expect(manage_api_request).to have_been_made
      end
    end
  end

  context 'when an authorised user tries to sync a nonexistent provider' do
    let!(:requester) { create(:user, email: email) }

    it 'raises an error' do
      manage_api_request = stub_manage_api_request(rolled_over_provider.provider_code)
      expect { sync_to_find("ABC") }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find Provider/)
      expect(manage_api_request).to_not have_been_made
    end
  end

  context 'when a non-existent user tries to sync an existing provider' do
    let!(:requester) { create(:user, email: 'someother@email.com') }

    it 'raises an error' do
      manage_api_request = stub_manage_api_request(rolled_over_provider.provider_code)
      expect { sync_to_find(rolled_over_provider.provider_code) }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find User/)
      expect(manage_api_request).to_not have_been_made
    end
  end

  context 'when an unauthorised user tries to sync an existing provider' do
    let!(:requester) { create(:user, email: email, organisations: []) }

    it 'raises an error' do
      manage_api_request = stub_manage_api_request(rolled_over_provider.provider_code)
      expect { sync_to_find(rolled_over_provider.provider_code) }.to raise_error(SystemExit)
      expect(manage_api_request).to_not have_been_made
    end
  end
end
