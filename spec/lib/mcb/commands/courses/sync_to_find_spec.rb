require 'mcb_helper'

describe 'mcb courses sync_to_find' do
  def sync_to_find(provider_code, *course_codes)
    with_stubbed_stdout do
      cmd.run([provider_code] + course_codes)
    end
  end

  let(:lib_dir) { Rails.root.join('lib') }
  let(:cmd) do
    Cri::Command.load_file("#{lib_dir}/mcb/commands/courses/sync_to_find.rb")
  end
  let(:provider_code) { 'X12' }
  let(:course_code) { '3FC4' }
  let(:email) { 'user@education.gov.uk' }
  let(:provider) { create(:provider, provider_code: provider_code) }
  let!(:course) { create(:course, provider: provider, course_code: course_code) }
  let!(:manage_api_request) {
    stub_request(:post, "#{Settings.manage_api.base_url}/api/Publish/internal/course/#{provider_code}/#{course_code}")
      .with { |req| req.body == { "email": email }.to_json }
      .to_return(
        status: 200,
        body: '{ "result": true }'
      )
  }

  before do
    allow(MCB).to receive(:config).and_return(email: email)
  end

  context 'when an authorised user' do
    let!(:requester) { create(:user, email: email, organisations: provider.organisations) }

    describe 'syncs an existing course' do
      it 'calls Manage API successfully' do
        expect { sync_to_find(provider_code, course_code) }.to_not raise_error
        expect(manage_api_request).to have_been_made
      end
    end

    describe 'tries to sync a nonexistent provider' do
      it 'raises an error' do
        expect { sync_to_find("ABC", course_code) }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find Provider/)
        expect(manage_api_request).to_not have_been_made
      end
    end

    describe 'provides no course codes' do
      it 'raises an error' do
        expect { sync_to_find(provider_code) }.to raise_error(ArgumentError, /No courses provided/)
        expect(manage_api_request).to_not have_been_made
      end
    end

    describe 'tries to sync a nonexistent course' do
      it 'raises an error' do
        expect { sync_to_find(provider_code, course_code, "ABCD") }.to raise_error(ArgumentError, /Couldn't find course ABCD/)
        expect(manage_api_request).to_not have_been_made
      end
    end
  end

  context 'when a non-existent user tries to sync an existing provider' do
    let!(:requester) { create(:user, email: 'someother@email.com') }

    it 'raises an error' do
      expect { sync_to_find(provider_code, course_code) }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find User/)
      expect(manage_api_request).to_not have_been_made
    end
  end

  context 'when an unauthorised user tries to sync an existing provider' do
    let!(:requester) { create(:user, email: email, organisations: []) }

    it 'raises an error' do
      expect { sync_to_find(provider_code, course_code) }.to raise_error(SystemExit)
      expect(manage_api_request).to_not have_been_made
    end
  end
end
