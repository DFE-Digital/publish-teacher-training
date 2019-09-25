require "rails_helper"

describe "PATCH /providers/:provider_code" do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
  let(:request_path) do
    "/api/v2/recruitment_cycles/#{recruitment_cycle.year}" +
      "/providers/#{provider.provider_code}"
  end
  let(:permitted_params) { %i[accredited_bodies] }
  let(:recruitment_cycle) { find_or_create :recruitment_cycle }
  let(:organisation) { create :organisation }
  let(:accrediting_provider) { create :provider }
  let(:course) { create :course, accrediting_provider: accrediting_provider }
  let(:courses) { [course] }
  let(:provider) do
    create :provider,
           organisations: [organisation],
           recruitment_cycle: recruitment_cycle,
           enrichments: enrichments,
           courses: courses
  end
  let(:user)         { create :user, organisations: [organisation] }
  let(:payload)      { { email: user.email } }
  let(:token)        { build_jwt :apiv2, payload: payload }
  let(:enrichments) { [] }
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end
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

  let(:enrichment_payload) do
    jsonapi_data = json_payload(provider)
    jsonapi_data.dig(:data, :attributes, :accredited_bodies, 0)[:description] = new_description
    jsonapi_data
  end

  context "provider with a single accrediting provider" do
    context "provider has no enrichments" do
      it "creates a draft enrichment for the provider with the accredited body enrichment" do
        expect {
          patch_request(enrichment_payload)
        }.to(change { provider.reload.enrichments.count }.from(0).to(1))

        expect(provider.enrichments.draft.first.accrediting_provider_enrichments.count).to eq(courses.size)

        accrediting_provider_enrichment = provider.enrichments.draft.first.accrediting_provider_enrichments.first
        expect(accrediting_provider_enrichment.Description).to eq(new_description)
        expect(accrediting_provider_enrichment.UcasProviderCode).to eq(accrediting_provider.provider_code)

        expect(response).to have_http_status(:ok)
        accredited_body = JSON.parse(response.body).dig("data", "attributes", "accredited_bodies").first

        expect(accredited_body.dig("provider_code")).to eq(accrediting_provider.provider_code)
        expect(accredited_body.dig("provider_name")).to eq(accrediting_provider.provider_name)
        expect(accredited_body.dig("description")).to eq(new_description)
      end

      context "failed validation" do
        let(:new_description) {
          Faker::Lorem.sentence(word_count: 101)
        }
        it "creates a draft enrichment for the provider with the accredited body enrichment" do
          expect {
            patch_request(enrichment_payload)
          }.to_not(change { provider.reload.enrichments.count })
        end
        let(:json_data) { JSON.parse(subject.body)["errors"] }
        subject do
          patch_request(enrichment_payload)
          response
        end

        it { should have_http_status(:unprocessable_entity) }

        it "has validation error details" do
          expect(json_data.count).to eq 1
          expect(json_data[0]["detail"]).to eq("Reduce the word count for #{accrediting_provider.provider_name}")
        end

        it "has validation error pointers" do
          expect(json_data[0]["source"]["pointer"]).to eq("/data/attributes/accredited_bodies")
        end
      end

      context "failed validation" do
        let(:new_description) {
          Faker::Lorem.sentence(word_count: 101)
        }
        it "creates a draft enrichment for the provider with the accredited body enrichment" do
          expect {
            patch_request(enrichment_payload)
          }.to_not(change { provider.reload.enrichments.count })
        end
        let(:json_data) { JSON.parse(subject.body)["errors"] }
        subject do
          patch_request(enrichment_payload)
          response
        end

        it { should have_http_status(:unprocessable_entity) }

        it "has validation error details" do
          expect(json_data.count).to eq 1
          expect(json_data[0]["detail"]).to eq("Reduce the word count for #{accrediting_provider.provider_name}")
        end

        it "has validation error pointers" do
          expect(json_data[0]["source"]["pointer"]).to eq("/data/attributes/accredited_bodies")
        end
      end
    end

    context "provider has only a single draft enrichments" do
      let(:enrichments) do
        [create(:provider_enrichment,
                accrediting_provider_enrichments: [{ "Description" => "old stuff", "UcasProviderCode" => accrediting_provider.provider_code }])]
      end

      it "updates an existing draft enrichment for the provider with the accredited body enrichment" do
        expect {
          patch_request(enrichment_payload)
        }.to_not(change { provider.reload.enrichments.count })

        expect(provider.enrichments.draft.first.accrediting_provider_enrichments.count).to eq(courses.size)

        accrediting_provider_enrichment = provider.enrichments.draft.first.accrediting_provider_enrichments.first
        expect(accrediting_provider_enrichment.Description).to eq(new_description)
        expect(accrediting_provider_enrichment.UcasProviderCode).to eq(accrediting_provider.provider_code)

        expect(response).to have_http_status(:ok)
        accredited_body = JSON.parse(response.body).dig("data", "attributes", "accredited_bodies").first

        expect(accredited_body.dig("provider_code")).to eq(accrediting_provider.provider_code)
        expect(accredited_body.dig("provider_name")).to eq(accrediting_provider.provider_name)
        expect(accredited_body.dig("description")).to eq(new_description)
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

    context "provider has no enrichments" do
      it "creates a draft enrichment for the provider with the accredited body enrichment" do
        expect {
          patch_request(enrichment_payload)
        }.to(change { provider.reload.enrichments.count }.from(0).to(1))

        expect(provider.enrichments.draft.first.accrediting_provider_enrichments.count).to eq(courses.size)
        accrediting_provider_enrichment = provider.enrichments.draft.first.accrediting_provider_enrichments.first

        expect(accrediting_provider_enrichment.Description).to eq(new_description)
        expect(accrediting_provider_enrichment.UcasProviderCode).to eq(accrediting_provider.provider_code)

        expect(response).to have_http_status(:ok)
        accredited_body = JSON.parse(response.body).dig("data", "attributes", "accredited_bodies").first

        expect(accredited_body.dig("provider_code")).to eq(accrediting_provider.provider_code)
        expect(accredited_body.dig("provider_name")).to eq(accrediting_provider.provider_name)
        expect(accredited_body.dig("description")).to eq(new_description)
      end
    end

    context "provider has only a single draft enrichments" do
      let(:enrichments) do
        [create(:provider_enrichment,
                accrediting_provider_enrichments: [{ "Description" => "old stuff", "UcasProviderCode" => accrediting_provider.provider_code }])]
      end

      it "updates an existing draft enrichment for the provider with the accredited body enrichment" do
        expect {
          patch_request(enrichment_payload)
        }.to_not(change { provider.reload.enrichments.count })

        expect(provider.enrichments.draft.first.accrediting_provider_enrichments.count).to eq(courses.size)

        accrediting_provider_enrichment = provider.enrichments.draft.first.accrediting_provider_enrichments.first
        expect(accrediting_provider_enrichment.Description).to eq(new_description)
        expect(accrediting_provider_enrichment.UcasProviderCode).to eq(accrediting_provider.provider_code)

        expect(response).to have_http_status(:ok)
        accredited_body = JSON.parse(response.body).dig("data", "attributes", "accredited_bodies").first

        expect(accredited_body.dig("provider_code")).to eq(accrediting_provider.provider_code)
        expect(accredited_body.dig("provider_name")).to eq(accrediting_provider.provider_name)
        expect(accredited_body.dig("description")).to eq(new_description)
      end
    end
  end
end
