require 'rails_helper'

describe 'force sync' do
  let(:credentials) do
    ActionController::HttpAuthentication::Token
      .encode_credentials('Ge32')
  end

  before do
    allow(BulkSyncCoursesToFindJob).to receive(:perform_later)
  end

  it 'returns success' do
    post '/api/system/sync', headers: { 'HTTP_AUTHORIZATION' => credentials }
    expect(response.status).to eq(202)
  end

  it 'triggers a sync' do
    post '/api/system/sync', headers: { 'HTTP_AUTHORIZATION' => credentials }
    expect(BulkSyncCoursesToFindJob).to have_received(:perform_later)
  end
end
