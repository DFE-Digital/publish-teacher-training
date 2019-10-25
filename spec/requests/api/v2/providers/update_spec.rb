require "rails_helper"

describe "PATCH /providers/:provider_code" do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
  let(:request_path) do
    "/api/v2/recruitment_cycles/#{recruitment_cycle.year}" +
      "/providers/#{provider.provider_code}"
  end

  def perform_request(provider)
    jsonapi_data = jsonapi_renderer.render(
      provider,
      class: {
        Provider: API::V2::SerializableProvider,
      },
    )

    jsonapi_data.dig(:data, :attributes).slice!(*permitted_params)
    perform_enqueued_jobs do
      patch request_path,
            headers: { "HTTP_AUTHORIZATION" => credentials },
            params: {
              _jsonapi: jsonapi_data,
              include: "latest_enrichment",
            }
    end
  end

  let(:recruitment_cycle) { find_or_create :recruitment_cycle }
  let(:organisation) { create :organisation }
  let(:site1) { build(:site_status, :findable) }
  let(:course1) { build(:course, level: "primary", site_statuses: [site1], subjects: [dfe_subject]) }
  let!(:dfe_subject) { find_or_create(:primary_subject, :primary) }
  let(:provider)     do
    create :provider,
           organisations: [organisation],
           recruitment_cycle: recruitment_cycle,
           courses: [course1]
  end
  let(:user)         { create :user, organisations: [organisation] }
  let(:payload)      { { email: user.email } }
  let(:token)        { build_jwt :apiv2, payload: payload }
  let(:enrichment)   { build(:provider_enrichment) }
  let(:update_provider) { provider.dup.tap { |p| updated_attributes.each { |attribute_name, attribute_value| p[attribute_name] = attribute_value } } }
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  let(:updated_attributes) do
    {
      email: "cats@cats4lyf.cat",
      website: "url",
      address1: "number",
      address2: "street",
      address3: "town",
      address4: "county",
      postcode: "sw1p 3bt",
      region_code: "london",
      telephone: "01234 567890",
      train_with_us: "train with us",
      train_with_disability: "train with disability",
    }
  end
  let(:permitted_params) do
    %i[
      email
      website
      address1
      address2
      address3
      address4
      postcode
      region_code
      telephone
      train_with_us
      train_with_disability
    ]
  end

  let(:search_api_status) { 200 }
  let(:sync_body) { WebMock::Matchers::AnyArgMatcher.new(nil) }
  let!(:sync_stub) do
    stub_request(:put, %r{#{Settings.search_api.base_url}/api/courses/})
      .with(body: sync_body)
      .to_return(
        status: search_api_status,
      )
  end

  describe "with permitted attributes on provider object" do
    it "returns ok" do
      perform_request update_provider

      expect(response).to be_ok
    end

    it "returns the updated provider" do
      perform_request update_provider

      json_response = JSON.parse(response.body)["data"]

      expect(json_response).to have_id(provider.id.to_s)
      expect(json_response).to have_type("providers")
      expect(json_response).to have_attribute(:email).with_value("cats@cats4lyf.cat")
      expect(json_response).to have_attribute(:website).with_value("url")
      expect(json_response).to have_attribute(:address1).with_value("number")
      expect(json_response).to have_attribute(:address2).with_value("street")
      expect(json_response).to have_attribute(:address3).with_value("town")
      expect(json_response).to have_attribute(:address4).with_value("county")
      expect(json_response).to have_attribute(:postcode).with_value("sw1p 3bt")
      expect(json_response).to have_attribute(:region_code).with_value("london")
      expect(json_response).to have_attribute(:telephone).with_value("01234 567890")
      expect(json_response).to have_attribute(:train_with_us).with_value("train with us")
      expect(json_response).to have_attribute(:train_with_disability).with_value("train with disability")
    end
  end
  describe "with unpermitted attributes on provider object" do
    shared_examples "does not allow assignment" do |attribute, value|
      it "doesn't permit #{attribute}" do
        update_provider[attribute] = if(attribute == :recruitment_cycle_id)
                                       next_cycle.id

                                     else

                                       value
                                     end
        perform_request(update_provider)
        expect(provider.reload.send(attribute)).not_to eq(value)
        expect(sync_stub).to have_been_requested
      end
    end

    include_examples "does not allow assignment", :id,                   9999
    include_examples "does not allow assignment", :provider_name,        "provider name"
    include_examples "does not allow assignment", :scheme_member,        :not_a_UCAS_ITT_member
    include_examples "does not allow assignment", :contact_name,         "contact name"
    include_examples "does not allow assignment", :year_code,            "year code"
    include_examples "does not allow assignment", :provider_code,        "provider code"
    include_examples "does not allow assignment", :provider_type,        :lead_school
    include_examples "does not allow assignment", :created_at,           Time.now
    include_examples "does not allow assignment", :updated_at,           Time.now
    include_examples "does not allow assignment", :accrediting_provider, :accredited_body
    include_examples "does not allow assignment", :last_published_at,    Time.now
    include_examples "does not allow assignment", :changed_at,           Time.now

    let!(:next_cycle) { find_or_create(:recruitment_cycle, :next) }
    include_examples "does not allow assignment", :recruitment_cycle_id

    context "attributes from other models" do
      let(:provider2) { create(:provider, courses: [course2], sites: [site]) }
      let(:course2) { build(:course) }
      let(:site) { build(:site) }

      before do
        provider2.id = provider.id
        perform_request(provider2)
      end

      subject { provider.reload }

      context "with a course" do
        its(:courses) { should_not include(course2) }
      end

      context "with sites" do
        its(:sites) { should_not include(site) }
      end

      it "syncs a provider's courses" do
        expect(sync_stub).to have_been_requested
      end
    end
  end

  context "with no attributes to update" do
    let(:updated_attributes) do
      {
        email: nil,
        website: nil,
        address1: nil,
        address2: nil,
        address3: nil,
        address4: nil,
        postcode: nil,
        region_code: nil,
        telephone: nil,
        train_with_us: nil,
        train_with_disability: nil,
      }
    end

    it "doesn't update provider" do
      expect {
        perform_request update_provider
      }.to_not(change { provider.reload })
    end
  end

  context "with empty attributes" do
    let(:permitted_params) { [] }

    it "doesn't update provider" do
      expect {
        perform_request update_provider
      }.to_not(change { provider.reload })
    end
  end

  context "with invalid data" do
    let(:updated_attributes) do
      {
        train_with_us: Faker::Lorem.sentence(word_count: 251),
        train_with_disability: Faker::Lorem.sentence(word_count: 251),
      }
    end

    subject {
      JSON.parse(response.body)["errors"].map { |e| e["title"] }
    }

    it "returns validation errors" do
      perform_request update_provider

      expect("Invalid train_with_us".in?(subject)).to eq(true)
      expect("Invalid train_with_disability".in?(subject)).to eq(true)
    end
  end

  context "with blank data" do
    let(:updated_attributes) do
      {
        train_with_us: "",
        train_with_disability: "",
      }
    end

    it "returns ok" do
      perform_request update_provider

      expect(response).to be_ok
    end
  end

  context "nil telephone number" do
    let(:updated_attributes) do
      { telephone: nil }
    end

    it "returns ok" do
      perform_request update_provider

      expect(response).to be_ok
    end
  end

  context "bad telephone number" do
    let(:updated_attributes) do
      { telephone: "CALL NOW 0123456789" }
    end

    subject { JSON.parse(response.body)["errors"].map { |e| e["title"] } }

    it "returns validation errors" do
      perform_request update_provider
      expect("Invalid enrichments".in?(subject)).to eq(false)
      expect("Invalid telephone".in?(subject)).to eq(true)
    end
  end
end
