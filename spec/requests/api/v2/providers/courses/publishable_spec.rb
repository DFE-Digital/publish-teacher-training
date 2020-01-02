require "rails_helper"

describe "Publishable API v2", type: :request do
  let(:user)         { create(:user) }
  let(:organisation) { create(:organisation, users: [user]) }
  let(:provider)     { create :provider, organisations: [organisation] }
  let(:payload)      { { email: user.email } }
  let(:token)        { build_jwt :apiv2, payload: payload }
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  describe "POST publishable" do
    let(:course) { findable_open_course }
    let(:publishable_path) do
      "/api/v2/providers/#{provider.provider_code}" +
        "/courses/#{course.course_code}/publishable"
    end

    let(:enrichment) { build(:course_enrichment, :initial_draft) }
    let(:site_status) { build(:site_status, :new) }
    let(:course) {
      create(:course,
             provider: provider,
             site_statuses: [site_status],
             enrichments: [enrichment])
    }

    subject do
      post publishable_path,
           headers: { "HTTP_AUTHORIZATION" => credentials },
           params: {
             _jsonapi: {
               data: {
                 attributes: {},
                 type: "course",
               },
             },
           }
      response
    end

    include_examples "Unauthenticated, unauthorised, or not accepted T&Cs"

    context "when course and provider is not related" do
      let(:course) { create(:course) }

      it { should have_http_status(:not_found) }
    end

    context "unpublished course with draft enrichment" do\
      let(:enrichment) { build(:course_enrichment, :initial_draft) }
      let(:primary_with_mathematics) { find_or_create(:primary_subject, :primary_with_mathematics) }
      let(:site_status) { build(:site_status, :new) }
      let!(:course) do
        create(:course,
               provider: provider,
               site_statuses: [site_status],
               enrichments: [enrichment],
               age: 17.days.ago,
               subjects: [primary_with_mathematics])
      end

      it "returns ok" do
        expect(subject).to have_http_status(:success)
      end
    end

    describe "failed validation" do
      let(:json_data) { JSON.parse(subject.body)["errors"] }

      context "no enrichments" do
        let(:course) { create(:course, provider: provider) }
        it { should have_http_status(:unprocessable_entity) }
        it "has validation errors" do
          expect(json_data.map { |error| error["detail"] }).to match_array([
            "Complete your course information before publishing",
            "You must pick at least one location for this course",
          ])
        end
      end

      context "fee type based course" do
        let(:course) {
          create(:course, :fee_type_based,
                 provider: provider,
                 enrichments: [invalid_enrichment],
                 site_statuses: [site_status])
        }

        context "invalid enrichment with invalid content lack_presence fields" do
          let(:invalid_enrichment) { create(:course_enrichment, :without_content) }

          it { should have_http_status(:unprocessable_entity) }

          it "has validation error details" do
            expect(json_data.count).to eq 5
            expect(json_data.map { |error| error["detail"] }).to match_array([
              "Enter details about this course",
              "Enter a course length",
              "Give details about the fee for UK and EU students",
              "Enter details about the qualifications needed",
              "Enter details about school placements",
            ])
          end

          it "has validation error pointers" do
            expect(json_data.map { |error| error["source"]["pointer"] }).to match_array([
              "/data/attributes/about_course",
              "/data/attributes/how_school_placements_work",
              "/data/attributes/course_length",
              "/data/attributes/fee_uk_eu",
              "/data/attributes/required_qualifications",
            ])
          end
        end
      end
    end
  end
end
