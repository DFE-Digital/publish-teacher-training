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

    if provider.enrichments.first.present?
      enrichment_data = provider.enrichments.first.slice(*permitted_params)
      jsonapi_data.dig(:data, :attributes).merge!(enrichment_data)
    end

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
  let!(:dfe_subject) { create(:primary_subject, :primary) }
  let(:provider)     do
    create :provider,
           organisations: [organisation],
           recruitment_cycle: recruitment_cycle,
           enrichments: enrichments,
           courses: [course1]
  end
  let(:user)         { create :user, organisations: [organisation] }
  let(:payload)      { { email: user.email } }
  let(:token)        { build_jwt :apiv2, payload: payload }
  let(:enrichment)   { build(:provider_enrichment) }
  let(:update_enrichment) { build :provider_enrichment, **updated_attributes }
  # we need an unsaved provider to add the enrichment to (so that it isn't
  # persisted)
  let(:update_provider) { provider.dup.tap { |p| p.enrichments << update_enrichment } }
  let(:enrichments) { [] }
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

  describe "with unpermitted attributes on provider object" do
    shared_examples "does not allow assignment" do |attribute, value|
      it "doesn't permit #{attribute}" do
        update_provider = build(:provider, attribute => value)
        update_provider.id = provider.id
        perform_request(provider)
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
    include_examples "does not allow assignment", :url,                  "url"
    include_examples "does not allow assignment", :created_at,           Time.now
    include_examples "does not allow assignment", :updated_at,           Time.now
    include_examples "does not allow assignment", :accrediting_provider, :accredited_body
    include_examples "does not allow assignment", :last_published_at,    Time.now
    include_examples "does not allow assignment", :changed_at,           Time.now
    include_examples "does not allow assignment", :recruitment_cycle_id, 9999

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

  context "provider has no enrichments" do
    it "creates a draft enrichment for the provider" do
      expect {
        perform_request update_provider
      }.to(change {
             provider.reload.enrichments.count
           }.from(0).to(1))

      draft_enrichment = provider.enrichments.draft.first

      expect(draft_enrichment.attributes.slice(*updated_attributes.keys.map(&:to_s)))
        .to include(updated_attributes.stringify_keys)
    end

    it "change content status" do
      expect {
        perform_request update_provider
      }.to(change { provider.reload.content_status }.from(:empty).to(:draft))
    end


    it "syncs a provider's courses" do
      perform_request update_provider

      expect(sync_stub).to have_been_requested
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

      it "doesn't create a draft provider enrichment" do
        expect {
          perform_request update_provider
        }.to_not(change { provider.reload.enrichments.count })
      end
    end

    context "with empty attributes" do
      let(:permitted_params) { [] }

      it "doesn't create a draft enrichment" do
        expect {
          perform_request update_provider
        }.to_not(change { provider.reload.enrichments.count })
      end

      it "doesn't change content status" do
        expect {
          perform_request update_provider
        }.to_not(change { provider.reload.content_status })
      end
    end

    it "returns ok" do
      perform_request update_provider

      expect(response).to be_ok
    end

    it "returns the updated provider with the enrichment included" do
      perform_request update_provider
      json_response = JSON.parse(response.body)["included"].first

      expect(json_response).to have_id(provider.reload.enrichments.first.id.to_s)
      expect(json_response).to have_type("provider_enrichment")
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
      expect(json_response).to have_attribute(:status).with_value("draft")
    end


    context "provider has a draft enrichment" do
      let(:enrichment) { build(:provider_enrichment) }
      let(:enrichments) { [enrichment] }

      it "syncs a provider's courses" do
        perform_request update_provider
        expect(sync_stub).to have_been_requested
      end

      it "updates the provider's draft enrichment" do
        expect {
          perform_request update_provider
        }.not_to(
          change { provider.enrichments.reload.count },
        )

        draft_enrichment = provider.enrichments.draft.first
        expect(draft_enrichment.attributes.slice(*updated_attributes.keys.map(&:to_s)))
          .to include(updated_attributes.stringify_keys)
      end

      it "doesn't change content status" do
        expect {
          perform_request update_provider
        }.to_not(change { provider.reload.content_status })
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

        it "doesn't change content status" do
          expect {
            perform_request update_provider
          }.to_not(change { provider.reload.content_status })
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

        it "doesn't change content status" do
          expect {
            perform_request update_provider
          }.to_not(change { provider.reload.content_status })
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

        it "doesn't change content status" do
          expect {
            perform_request update_provider
          }.to_not(change { provider.reload.content_status })
        end

        it "doesn't add an enrichment" do
          expect { perform_request update_provider }
          .to_not(
            change { provider.enrichments.reload.count },
          )
        end
      end
    end

    context "provider has only a published enrichment" do
      let(:enrichment) { build :provider_enrichment, :published }
      let(:enrichments) { [enrichment] }

      it "syncs a provider's courses" do
        perform_request update_provider

        expect(sync_stub).to have_been_requested
      end

      it "creates a draft enrichment for the provider" do
        expect { perform_request update_provider }
          .to(
            change { provider.enrichments.reload.draft.count }
              .from(0).to(1),
          )

        draft_enrichment = provider.enrichments.draft.first
        expect(draft_enrichment.attributes.slice(*updated_attributes.keys.map(&:to_s)))
          .to include(updated_attributes.stringify_keys)
      end

      it do
        expect { perform_request update_provider }
        .to(
          change { provider.enrichments.reload.count }
            .from(1).to(2),
        )
      end

      it "change content status" do
        expect {
          perform_request update_provider
        }.to(change { provider.reload.content_status }.from(:published).to(:published_with_unpublished_changes))
      end

      context "with invalid data" do
        let(:updated_attributes) do
          { train_with_us: Faker::Lorem.sentence(word_count: 251) }
        end

        subject { JSON.parse(response.body)["errors"].map { |e| e["title"] } }

        it "returns validation errors" do
          perform_request update_provider

          expect("Invalid enrichments".in?(subject)).to eq(false)
          expect("Invalid train_with_us".in?(subject)).to eq(true)
        end

        it "does not syncs a provider's courses" do
          perform_request update_provider

          expect(sync_stub).to_not have_been_requested
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

        it "doesn't change content status" do
          expect {
            perform_request update_provider
          }.to_not(change { provider.reload.content_status })
        end

        it "doesn't add an enrichment" do
          expect { perform_request update_provider }
          .to_not(
            change { provider.enrichments.reload.count },
          )
        end

        it "does not syncs a provider's courses" do
          perform_request update_provider

          expect(sync_stub).to_not have_been_requested
        end
      end
    end
  end

  describe "from published to draft" do
    shared_examples "only one attribute has changed" do |attribute_key, attribute_value, jsonapi_serialized_name|
      describe "a subsequent draft enrichment is added" do
        let(:updated_attributes) do
          attribute = {}
          attribute[attribute_key] = attribute_value
          attribute
        end

        let(:permitted_params) {
          if jsonapi_serialized_name.blank?
            [attribute_key]
          else
            [jsonapi_serialized_name]
          end
        }

        before do
          perform_request update_provider
        end

        subject {
          provider.reload
        }

        its(:content_status) { should eq :published_with_unpublished_changes }

        it "set #{attribute_key}" do
          expect(subject.enrichments.draft.first[attribute_key]).to eq(attribute_value)
        end

        it "syncs a provider's courses" do
          expect(sync_stub).to have_been_requested
        end

        enrichments_attributes_key = %i[
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
        ].freeze

        published_enrichment_attributes = (enrichments_attributes_key.filter { |x| x != attribute_key }).freeze

        published_enrichment_attributes.each do |published_enrichment_attribute|
          it "set #{published_enrichment_attribute} using published enrichment" do
            expect(subject.enrichments.draft.first[published_enrichment_attribute]).to eq(original_enrichment[published_enrichment_attribute])
          end
        end
      end
    end

    let(:original_enrichment) { build :provider_enrichment, :published, created_at: Date.yesterday }
    let(:enrichments) { [original_enrichment] }

    include_examples "only one attribute has changed", :email, "changed@email_address.com"
    include_examples "only one attribute has changed", :website, "changed url"
    include_examples "only one attribute has changed", :address1, "changed number"
    include_examples "only one attribute has changed", :address2, "changed street"
    include_examples "only one attribute has changed", :address3, "changed town"
    include_examples "only one attribute has changed", :address4, "changed county"
    include_examples "only one attribute has changed", :postcode, "changed sw1p 3bt"
    include_examples "only one attribute has changed", :region_code, "yorkshire_and_the_humber"
    include_examples "only one attribute has changed", :telephone, "01234 999999"
    include_examples "only one attribute has changed", :train_with_us, "changed train with us"
    include_examples "only one attribute has changed", :train_with_disability, "changed train with disability"
  end

  describe "Updating a rolled over enrichment" do
    let(:enrichment) { build :provider_enrichment, status: "rolled_over" }
    let(:enrichments) { [enrichment] }

    let(:updated_enrichment) { enrichment.reload }

    before do
      perform_request update_provider
    end

    it "Sets the provider enrichment status to draft" do
      expect(updated_enrichment.status).to eq("draft")
    end

    it "syncs a provider's courses" do
      expect(sync_stub).to have_been_requested
    end
  end
end
