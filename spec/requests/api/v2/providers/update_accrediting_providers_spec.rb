require "rails_helper"

describe "PATCH /providers/:provider_code" do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
  let(:enrichment_payload) do
    jsonapi_data = json_payload(provider)
    jsonapi_data.dig(:data, :attributes, :accredited_bodies, 0)[:description] = new_description
    jsonapi_data
  end
  let(:request_path) do
    "/api/v2/recruitment_cycles/#{recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}"
  end
  let(:permitted_params) { %i[accredited_bodies] }
  let(:recruitment_cycle) { find_or_create :recruitment_cycle }
  let(:accrediting_provider) { create :provider, provider_code: "AP2" }
  let(:course) { create :course, accrediting_provider: accrediting_provider, course_code: "P33P" }
  let(:courses) { [course] }
  let(:accrediting_provider_enrichments) { nil }
  let(:provider) do
    create :provider,
           users: [user],
           recruitment_cycle: recruitment_cycle,
           accrediting_provider_enrichments: accrediting_provider_enrichments,
           courses: courses
  end
  let(:user)         { create :user }
  let(:payload)      { { email: user.email } }
  let(:credentials) { encode_to_credentials(payload) }
  let(:new_description) { "new description" }

  def json_payload(provider)
    jsonapi_data = jsonapi_renderer.render(
      provider,
      class: {
        Provider: API::V2::SerializableProvider,
      },
    )
    jsonapi_data.dig(:data, :attributes).slice!(*permitted_params)
    jsonapi_data
  end

  def patch_request(jsonapi_data)
    patch request_path,
          headers: { "HTTP_AUTHORIZATION" => credentials },
          params: {
            _jsonapi: jsonapi_data,
          }
  end

  before do
    provider.reload
    # NOTE: provider needs to be reloaded due to
    #       provider.accrediting_providers
    #       provider.accredited_bodies
  end

  context "provider has no accredited body enrichment" do
    it "creates a accredited body enrichment" do
      expect {
        patch_request(enrichment_payload)
      }.to(change { provider.reload.accrediting_provider_enrichments.present? }.from(false).to(true))

      expect(provider.accrediting_provider_enrichments.count).to eq(courses.size)

      accrediting_provider_enrichment = provider.accrediting_provider_enrichments.first
      expect(accrediting_provider_enrichment.Description).to eq(new_description)
      expect(accrediting_provider_enrichment.UcasProviderCode).to eq(accrediting_provider.provider_code)

      expect(response).to have_http_status(:ok)
      accredited_body = JSON.parse(response.body).dig("data", "attributes", "accredited_bodies").first

      expect(accredited_body["provider_code"]).to eq(accrediting_provider.provider_code)
      expect(accredited_body["provider_name"]).to eq(accrediting_provider.provider_name)
      expect(accredited_body["description"]).to eq(new_description)
    end

    context "failed validation" do
      let(:new_description) {
        Faker::Lorem.sentence(word_count: 101)
      }
      let(:json_data) { JSON.parse(subject.body)["errors"] }
      let(:json_data) { JSON.parse(subject.body)["errors"] }

      it "creates a accredited body enrichment" do
        expect {
          patch_request(enrichment_payload)
        }.not_to(change { provider.reload.accrediting_provider_enrichments.present? })
      end

      subject do
        patch_request(enrichment_payload)
        response
      end

      it { is_expected.to have_http_status(:unprocessable_entity) }

      it "has validation error details" do
        expect(json_data.count).to eq 1
        expect(json_data[0]["detail"]).to eq("Reduce the word count for #{accrediting_provider.provider_name}")
      end

      it "has validation error pointers" do
        expect(json_data[0]["source"]["pointer"]).to eq("/data/attributes/accredited_bodies")
      end
    end
  end

  context "provider has only an accredited body enrichment" do
    let(:old_description) { "old stuff" }
    let(:accrediting_provider_enrichments) do
      [{ "Description" => old_description, "UcasProviderCode" => accrediting_provider.provider_code }]
    end

    it "updates an existing accredited body enrichment" do
      expect {
        patch_request(enrichment_payload)
      }.not_to(change { provider.reload.accrediting_provider_enrichments.size })

      expect(provider.accrediting_provider_enrichments.count).to eq(courses.size)

      accrediting_provider_enrichment = provider.accrediting_provider_enrichments.first
      expect(accrediting_provider_enrichment.Description).to eq(new_description)
      expect(accrediting_provider_enrichment.UcasProviderCode).to eq(accrediting_provider.provider_code)

      expect(response).to have_http_status(:ok)
      accredited_body = JSON.parse(response.body).dig("data", "attributes", "accredited_bodies").first

      expect(accredited_body["provider_code"]).to eq(accrediting_provider.provider_code)
      expect(accredited_body["provider_name"]).to eq(accrediting_provider.provider_name)
      expect(accredited_body["description"]).to eq(new_description)
    end

    context "failed validation" do
      let(:new_description) {
        Faker::Lorem.sentence(word_count: 101)
      }
      let(:json_data) { JSON.parse(subject.body)["errors"] }

      let(:json_data) { JSON.parse(subject.body)["errors"] }

      it "did not updates an existing accredited body enrichment" do
        expect {
          patch_request(enrichment_payload)
        }.not_to(change { provider.reload.accrediting_provider_enrichments.size })

        accrediting_provider_enrichment = provider.accrediting_provider_enrichments.first
        expect(accrediting_provider_enrichment.Description).to eq(old_description)
        expect(accrediting_provider_enrichment.UcasProviderCode).to eq(accrediting_provider.provider_code)
      end

      subject do
        patch_request(enrichment_payload)
        response
      end

      it { is_expected.to have_http_status(:unprocessable_entity) }

      it "has validation error details" do
        expect(json_data.count).to eq 1
        expect(json_data[0]["detail"]).to eq("Reduce the word count for #{accrediting_provider.provider_name}")
      end

      it "has validation error pointers" do
        expect(json_data[0]["source"]["pointer"]).to eq("/data/attributes/accredited_bodies")
      end
    end
  end

  context "provider with multiple accrediting providers" do
    let(:additional_acrediting_courses) {
      result = []
      10.times { result << create(:course, accrediting_provider: create(:provider)) }
      result
    }

    let(:courses) { [course] + additional_acrediting_courses }

    context "provider has no accredited body enrichments" do
      it "creates multiple accredited body enrichment" do
        expect {
          patch_request(enrichment_payload)
        }.to(change { provider.reload.accrediting_provider_enrichments.present? }.from(false).to(true))

        expect(provider.accrediting_provider_enrichments.count).to eq(courses.size)
        accrediting_provider_enrichment = provider.accrediting_provider_enrichments.first

        expect(accrediting_provider_enrichment.Description).to eq(new_description)
        expect(accrediting_provider_enrichment.UcasProviderCode).to eq(accrediting_provider.provider_code)

        expect(response).to have_http_status(:ok)
        accredited_body = JSON.parse(response.body).dig("data", "attributes", "accredited_bodies").first

        expect(accredited_body["provider_code"]).to eq(accrediting_provider.provider_code)
        expect(accredited_body["provider_name"]).to eq(accrediting_provider.provider_name)
        expect(accredited_body["description"]).to eq(new_description)
      end
    end

    context "provider has only a single accrediting provider enrichments" do
      let(:accrediting_provider_enrichments) do
        [{ "Description" => "old stuff", "UcasProviderCode" => accrediting_provider.provider_code }]
      end

      it "updates an existing accredited body enrichment" do
        expect {
          patch_request(enrichment_payload)
        }.not_to(change { provider.reload.accrediting_provider_enrichments.present? })

        expect(provider.accrediting_provider_enrichments.count).to eq(courses.size)

        accrediting_provider_enrichment = provider.accrediting_provider_enrichments.first
        expect(accrediting_provider_enrichment.Description).to eq(new_description)
        expect(accrediting_provider_enrichment.UcasProviderCode).to eq(accrediting_provider.provider_code)

        expect(response).to have_http_status(:ok)
        accredited_body = JSON.parse(response.body).dig("data", "attributes", "accredited_bodies").first

        expect(accredited_body["provider_code"]).to eq(accrediting_provider.provider_code)
        expect(accredited_body["provider_name"]).to eq(accrediting_provider.provider_name)
        expect(accredited_body["description"]).to eq(new_description)
      end
    end
  end
end
