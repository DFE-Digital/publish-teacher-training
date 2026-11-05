# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Public API key authentication", service: :api do
  let(:path) { "/api/public/v1/subjects" }
  let(:secret) { create(:api_key).secret }
  let(:unknown_key_header) { { "Authorization" => "Bearer #{APIKey::SECRET_PREFIX}#{'0' * 64}" } }

  def bearer(token) = { "Authorization" => "Bearer #{token}" }

  it "serves a request with no header, and a valid key exactly the same" do
    find_or_create(:primary_subject, :primary)

    get path
    anonymous_body = response.parsed_body

    get path, headers: bearer(secret)

    expect(response).to have_http_status(:ok)
    expect(anonymous_body["data"]).not_to be_empty
    expect(response.parsed_body).to eq(anonymous_body)
  end

  it "accepts the Bearer scheme in any case and after any run of spaces" do
    get path, headers: { "Authorization" => "bEARER  #{secret}" }

    expect(response).to have_http_status(:ok)
  end

  it "rejects an unknown key with a JSON error and a challenge" do
    get path, headers: unknown_key_header

    expect(response).to have_http_status(:unauthorized)
    expect(response.headers["WWW-Authenticate"]).to eq("Bearer")
    expect(response.parsed_body).to eq(
      "errors" => [
        {
          "status" => 401,
          "title" => "UNAUTHORIZED",
          "detail" => "The API key was not accepted. Send an active key in the Authorization header using the Bearer scheme, and never in the URL",
        },
      ],
    )
  end

  it "rejects a revoked key" do
    api_key = create(:api_key)
    api_key.revoke!

    get path, headers: bearer(api_key.secret)

    expect(response).to have_http_status(:unauthorized)
  end

  {
    "an empty header" => ->(_secret) { "" },
    "a Bearer scheme with no token" => ->(_secret) { "Bearer " },
    "a real key under the Token scheme" => ->(secret) { "Token #{secret}" },
    "a real key with no scheme" => ->(secret) { secret },
    "a real key followed by a second token" => ->(secret) { "Bearer #{secret} extra" },
    "bytes that are not valid UTF-8" => ->(_secret) { "Bearer \xFF" },
  }.each do |description, credential|
    it "rejects #{description}" do
      get path, headers: { "Authorization" => credential.call(secret) }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  it "does not look up a token that is not key-shaped" do
    allow(APIKey).to receive(:find_active_by_secret)

    get path, headers: bearer("nope")

    expect(response).to have_http_status(:unauthorized)
    expect(APIKey).not_to have_received(:find_active_by_secret)
  end

  describe "a key-shaped value in the query string" do
    it "is rejected under any param name" do
      %w[api_key q].each do |name|
        get "#{path}?#{name}=#{secret}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    it "is rejected alongside a valid header" do
      get "#{path}?api_key=#{secret}", headers: bearer(secret)

      expect(response).to have_http_status(:unauthorized)
    end

    it "is rejected when sent as a param name, with or without a value" do
      ["#{secret}=1", secret].each do |query|
        get "#{path}?#{query}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    it "is rejected when encoded twice" do
      get "#{path}?q=#{secret.sub('p', '%2570')}"

      expect(response).to have_http_status(:unauthorized)
    end

    it "gets the same error as a bad header" do
      get path, headers: unknown_key_header
      header_error = [response.body, response.media_type, response.headers["WWW-Authenticate"]]

      get "#{path}?#{secret}=1"

      expect([response.body, response.media_type, response.headers["WWW-Authenticate"]]).to eq(header_error)
    end

    it "is rejected before the request logger or controller runs" do
      events = []

      ActiveSupport::Notifications.subscribed(->(name, *) { events << name }, /\.action_(dispatch|controller)\z/) do
        get "#{path}?#{secret}=1"
      end

      expect(response).to have_http_status(:unauthorized)
      expect(events).to be_empty
    end

    it "leaves a value that is not key-shaped alone" do
      get "#{path}?api_key=garbage"

      expect(response).to have_http_status(:ok)
    end

    context "with request analytics on" do
      before do
        allow(FeatureService).to receive(:enabled?).and_call_original
        allow(FeatureService).to receive(:enabled?).with(:send_request_data_to_bigquery).and_return(true)
      end

      it "sends no analytics event, which an anonymous request does" do
        expect { get "#{path}?api_key=#{secret}" }.not_to have_sent_analytics_event_types(:web_request)
        expect { get path }.to have_sent_analytics_event_types(:web_request)
      end
    end
  end

  describe "a key-shaped value in the path" do
    it "is rejected in a segment a route would accept, and in an over-encoded query" do
      [
        "/api/public/v1/recruitment_cycles/#{secret}/providers",
        "#{path}%3Fapi_key=#{secret}",
      ].each do |url|
        get url

        expect(response).to have_http_status(:unauthorized)
      end
    end

    it "is rejected before the request logger or controller runs" do
      events = []

      ActiveSupport::Notifications.subscribed(->(name, *) { events << name }, /\.action_(dispatch|controller)\z/) do
        get "/api/public/v1/recruitment_cycles/#{secret}/providers"
      end

      expect(response).to have_http_status(:unauthorized)
      expect(events).to be_empty
    end
  end

  it "does not let a conditional request skip validation" do
    get path
    etag = response.headers["ETag"]

    get path, headers: unknown_key_header.merge("If-None-Match" => etag)
    expect(response).to have_http_status(:unauthorized)

    get path, headers: { "If-None-Match" => etag }
    expect(response).to have_http_status(:not_modified)
  end

  it "guards every routed public API endpoint" do
    routes = Rails.application.routes.routes.select { |route| route.path.spec.to_s.start_with?("/api/public/v1") }
    routes = routes.reject { |route| route.defaults.values_at(:controller, :action) == %w[api/public/v1/recruitment_cycles show] }

    statuses = routes.to_h do |route|
      route_path = route.path.spec.to_s.delete_suffix("(.:format)").gsub(/:\w+/, "x")
      get route_path, headers: unknown_key_header

      [route_path, response.status]
    end

    expect(statuses).not_to be_empty
    expect(statuses).to eq(statuses.transform_values { 401 })
  end

  context "on the internal API", service: :publish do
    it "reaches the suggestion endpoints with an unknown key" do
      year = find_or_create(:recruitment_cycle).year

      statuses = [
        "/api/school_suggestions",
        "/api/radius_quick_link_suggestions",
        "/api/#{year}/accredited_provider_suggestions",
      ].map do |internal_path|
        get internal_path, headers: unknown_key_header

        response.status
      end

      expect(statuses).to eq([400, 200, 400])
    end

    it "rejects a key-shaped value in the query string" do
      get "/api/school_suggestions?q=#{secret}"

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
