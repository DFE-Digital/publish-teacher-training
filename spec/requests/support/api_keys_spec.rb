# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support::APIKeysController" do
  include DfESignInUserHelper

  let(:submission_token) { SecureRandom.uuid }
  let(:api_key_params) { { submission_token:, api_key: { name: "Teacher Vacancies", email: "vacancies@example.org" } } }

  before do
    host! URI(Settings.base_url).host
    login_user(create(:user, :admin))
  end

  it "forbids caching the page that shows the new key" do
    FeatureFlag.activate(:api_keys)

    post support_api_keys_path, params: api_key_params

    expect(response).to have_http_status(:created)
    expect(response.headers["Cache-Control"]).to eq("no-store")
  end

  it "ignores a search that is not a single string" do
    FeatureFlag.activate(:api_keys)
    create(:api_key, name: "Apply")

    get support_api_keys_path, params: { text_search: %w[Apply] }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Apply")
  end

  it "asks for the missing detail when a field is left out of the post" do
    FeatureFlag.activate(:api_keys)

    post support_api_keys_path, params: { submission_token:, api_key: { name: "Teacher Vacancies" } }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Enter an email address")
  end

  it "creates one key when the same form is submitted twice" do
    FeatureFlag.activate(:api_keys)

    2.times { post support_api_keys_path, params: api_key_params }

    expect(response).to have_http_status(:conflict)
    expect(response.body).to include("This API key was already created")
    expect(APIKey.count).to eq(1)
  end

  it "guards a corrected form against being submitted twice" do
    FeatureFlag.activate(:api_keys)

    post support_api_keys_path, params: api_key_params.deep_merge(api_key: { name: "" })
    resubmitted_token = Nokogiri::HTML(response.body).at("input[name=submission_token]")["value"]
    2.times { post support_api_keys_path, params: api_key_params.merge(submission_token: resubmitted_token) }

    expect(response).to have_http_status(:conflict)
    expect(APIKey.count).to eq(1)
  end

  it "has no API keys routes while the api_keys flag is inactive" do
    get support_api_keys_path
    expect(response).to have_http_status(:not_found)

    post support_api_keys_path, params: api_key_params
    expect(response).to have_http_status(:not_found)
    expect(APIKey.count).to eq(0)
  end
end
