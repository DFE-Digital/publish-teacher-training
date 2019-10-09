require "rails_helper"

describe "Publish API v2", type: :request do
  let(:user)         { create(:user) }
  let(:organisation) { create(:organisation, users: [user]) }
  let(:provider)       { create :provider, organisations: [organisation] }
  let(:payload)      { { email: user.email } }
  let(:token)        { build_jwt :apiv2, payload: payload }
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  describe "POST publish" do
    let(:status) { 200 }
    let(:course) { findable_open_course }
    let(:publish_path) do
      "/api/v2/recruitment_cycles/#{provider.recruitment_cycle.year}/providers/#{provider.provider_code}" +
        "/courses/#{course.course_code}/publish"
    end

    before do
      stub_request(:put, "#{Settings.search_api.base_url}/api/courses/")
        .to_return(
          status: status,
        )
    end
    let(:enrichment) { build(:course_enrichment, :initial_draft) }
    let(:site_status) { build(:site_status, :new) }
    let(:dfe_subject) { build(:subject, :primary) }
    let(:course) {
      create(:course,
             provider: provider,
             site_statuses: [site_status],
             enrichments: [enrichment],
             subjects: [dfe_subject])
    }

    subject do
      post publish_path,
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

    context "an unpublished course with a draft enrichment" do
      let(:enrichment) { build(:course_enrichment, :initial_draft) }
      let(:site_status) { build(:site_status, :new) }
      let(:dfe_subjects) { [build(:subject, :primary)] }
      let!(:course) {
        create(:course,
               provider: provider,
               site_statuses: [site_status],
               enrichments: [enrichment],
               subjects: dfe_subjects,
               age: 17.days.ago)
      }

      before do
        Timecop.freeze
      end

      after do
        Timecop.return
      end

      context "in the current cycle" do
        it "publishes a course" do
          perform_enqueued_jobs do
            expect(subject).to have_http_status(:success)
          end

          assert_requested :put, "#{Settings.search_api.base_url}/api/courses/"

          expect(course.reload.site_statuses.first).to be_status_running
          expect(course.site_statuses.first).to be_published_on_ucas
          expect(course.enrichments.first).to be_published
          expect(course.enrichments.first.updated_by_user_id).to eq user.id
          expect(course.enrichments.first.updated_at).to be_within(1.second).of Time.now.utc
          expect(course.enrichments.first.last_published_timestamp_utc).to be_within(1.second).of Time.now.utc
          expect(course.changed_at).to be_within(1.second).of Time.now.utc
        end
      end

      context "in the next cycle" do
        let(:provider) { create :provider, :next_recruitment_cycle, organisations: [organisation] }

        it "publishes a course" do
          perform_enqueued_jobs do
            expect(subject).to have_http_status(:success)
          end

          assert_requested :put, "#{Settings.search_api.base_url}/api/courses/"

          expect(course.reload.site_statuses.first).to be_status_running
          expect(course.site_statuses.first).to be_published_on_ucas
          expect(course.enrichments.first).to be_published
          expect(course.enrichments.first.updated_by_user_id).to eq user.id
          expect(course.enrichments.first.updated_at).to be_within(1.second).of Time.now.utc
          expect(course.enrichments.first.last_published_timestamp_utc).to be_within(1.second).of Time.now.utc
          expect(course.changed_at).to be_within(1.second).of Time.now.utc
        end
      end

      # In production this job would be performed asynchronous, but in tests
      # it's synchronous. Which is handy for testing what happens when
      # search-and-compare returns an error, otherwise the error would be
      # thrown in the delayed_job process.
      context "performing the job synchronously and search-and-compare failing the request " do
        let(:status) { 404 }

        it "raises an error" do
          expect {
            perform_enqueued_jobs do
              subject
            end
          }.to(raise_error(
                 RuntimeError,
                 "Error 404 received syncing courses: #{course}",
               ))
        end
      end
    end

    describe "failed validation" do
      let(:json_data) { JSON.parse(subject.body)["errors"] }

      context "no enrichments, sites and subjects" do
        let(:course) { create(:course, provider: provider, enrichments: [], site_statuses: []) }
        it { should have_http_status(:unprocessable_entity) }
        it "has validation errors" do
          expect(json_data.map { |error| error["detail"] }).to match_array([
            "Complete your course information before publishing",
            "There is a problem with this course. Contact support to fix it (Error: S)",
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
            expect(json_data.map { |error| error["detail"] }).to match_array([
              "Enter details about this course",
              "Enter details about school placements",
              "Enter a course length",
              "Give details about the fee for UK and EU students",
              "Enter details about the qualifications needed",
              "There is a problem with this course. Contact support to fix it (Error: S)",
            ])
          end

          it "has validation error pointers" do
            expect(json_data.map { |error| error["source"]["pointer"] }).to match_array([
              nil,
              "/data/attributes/about_course",
              "/data/attributes/how_school_placements_work",
              "/data/attributes/course_length",
              "/data/attributes/fee_uk_eu",
              "/data/attributes/required_qualifications",
            ])
          end
        end
      end

      context "salary type based course" do
        let(:course) {
          create(:course, :salary_type_based,
                 provider: provider,
                 enrichments: [invalid_enrichment],
                 site_statuses: [site_status])
        }

        context "invalid enrichment with invalid content lack_presence fields" do
          let(:invalid_enrichment) { create(:course_enrichment, :without_content) }

          it { should have_http_status(:unprocessable_entity) }

          it "has validation errors" do
            expect(json_data.map { |error| error["detail"] }).to match_array([
              "Enter details about this course",
              "Enter details about school placements",
              "Enter a course length",
              "Give details about the salary for this course",
              "Enter details about the qualifications needed",
              "There is a problem with this course. Contact support to fix it (Error: S)",
            ])
          end
        end
      end
    end
  end
end
