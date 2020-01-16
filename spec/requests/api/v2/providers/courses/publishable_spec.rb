require "rails_helper"

describe "Publishable API v2", type: :request do
  let(:course)        { TestSetup.unpub_pri_math }
  let(:provider)      { course.provider }
  let(:organisation)  { provider.organisations.first }
  let(:user)          { provider.users.first }
  let(:payload)       { { email: user.email } }
  let(:token)         { build_jwt :apiv2, payload: payload }
  let(:credentials)   { ActionController::HttpAuthentication::Token.encode_credentials(token) }

  describe "POST publishable" do
    let(:publishable_path) do
      "/api/v2/providers/#{provider.provider_code}" +
        "/courses/#{course.course_code}/publishable"
    end

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
      let(:provider) { create(:provider) }

      it { should have_http_status(:not_found) }
    end

    context "unpublished course with draft enrichment" do
      let(:course) {
        create(:course, :unpublished_with_primary_maths, :draft_enrichment)
      }

      it "returns ok" do
        expect(subject).to have_http_status(:success)
      end
    end

    describe "failed validation" do
      let(:json_data) { JSON.parse(subject.body)["errors"] }

      context "no enrichments and location" do
        let(:course) {
          create(:course, :unpublished_with_primary_maths,
                 site_statuses: [],
                 enrichments: [])
        }

        it { should have_http_status(:unprocessable_entity) }
        it "has validation errors" do
          expect(json_data.map { |error| error["detail"] }).to match_array([
            "Complete your course information before publishing",
            "You must pick at least one location for this course",
          ])
        end
      end

      context "fee type based course" do
        context "invalid enrichment with invalid content lack_presence fields" do
          let(:course) {
            create(:course, :fee_type_based, :unpublished_with_primary_maths,
                   enrichments: [build(:course_enrichment, :without_content)])
          }

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
            expect(json_data.map { |error| error["source"]["pointer"] }).to match_array(%w(
              /data/attributes/about_course
              /data/attributes/how_school_placements_work
              /data/attributes/course_length
              /data/attributes/fee_uk_eu
              /data/attributes/required_qualifications
            ))
          end
        end
      end
    end
  end
end
