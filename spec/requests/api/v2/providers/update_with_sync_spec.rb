require "rails_helper"

fdescribe "Provider Publish API v2", type: :request do
  let(:user)         { create(:user) }
  let(:organisation) { create(:organisation, users: [user]) }
  let(:provider)     do
    create(:provider, organisations: [organisation])
  end
  let(:payload)      { { email: user.email } }
  let(:token)        { build_jwt :apiv2, payload: payload }
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  describe "PATCH /providers/:provider_code" do
    let(:publish_path) do
      "/api/v2/recruitment_cycles/#{provider.recruitment_cycle.year}" +
        "/providers/#{provider.provider_code}"
    end

    let(:enrichment) { build(:provider_enrichment, :initial_draft) }

    subject do
      patch publish_path,
            headers: { "HTTP_AUTHORIZATION" => credentials },
            params: {
              _jsonapi: {
                data: {
                  attributes: {},
                  type: "provider",
                },
              },
            }
      response
    end

    include_examples "Unauthenticated, unauthorised, or not accepted T&Cs"

    context "sync provider with latests enrichments" do
      let(:enrichment) { build(:provider_enrichment, :initial_draft) }
      let(:site1) { create(:site_status, :findable) }
      let(:site2) { create(:site_status, :findable) }
      let(:course1) { build(:course, site_statuses: [site1], subjects: [dfe_subject]) }
      let(:course2) { build(:course, site_statuses: [site2], subjects: [dfe_subject]) }

      let!(:dfe_subject) { build(:subject, :primary) }

      let(:courses) {
        []
      }

      let(:search_api_status) { 200 }
      let(:sync_body) { WebMock::Matchers::AnyArgMatcher.new(nil) }
      let!(:sync_stub) do
        stub_request(:put, %r{#{Settings.search_api.base_url}/api/courses/})
          .with(body: sync_body)
          .to_return(
            status: search_api_status,
          )
      end

      describe "current recruitment cycle" do
        let!(:provider) do
          create(
            :provider,
            organisations: [organisation],
            enrichments: [enrichment],
            courses: courses,
          )
        end

        describe "only syncable courses on provider" do
          context "no courses" do
            it "does not syncs a provider's courses" do
              perform_enqueued_jobs do
                subject
              end
              expect(sync_stub).to_not have_been_requested
            end
          end
          context "its fine" do
            let(:courses) {
              [course1, course2]
            }
            let(:sync_body) do include("\"ProgrammeCode\":\"#{course1.course_code}\"", "\"ProgrammeCode\":\"#{course2.course_code}\"") end

            it "syncs a provider's courses" do
              perform_enqueued_jobs do
                subject
              end
              expect(sync_stub).to have_been_requested
            end
          end

          context "mixed" do
            let(:course3) { build(:course) }
            let(:courses) {
              [course1, course3]
            }
            let(:sync_body) do include("\"ProgrammeCode\":\"#{course1.course_code}\"") end
            it "does syncs a provider's courses" do
              perform_enqueued_jobs do
                subject
              end
              expect(sync_stub).to have_been_requested
            end
          end
        end
      end

      describe "next recruitment cycle" do
        let!(:provider) do
          create(
            :provider,
            :next_recruitment_cycle,
            organisations: [organisation],
            enrichments: [enrichment],
            courses: courses,
          )
        end

        describe "only syncable courses on provider" do
          context "no courses" do
            it "does not syncs a provider's courses" do
              perform_enqueued_jobs do
                subject
              end
              expect(sync_stub).to_not have_been_requested
            end
          end
          context "its fine" do
            let(:courses) {
              [course1, course2]
            }

            it "does not syncs a provider's courses" do
              perform_enqueued_jobs do
                subject
              end
              expect(sync_stub).to_not have_been_requested
            end
          end
          context "mixed" do
            let(:course3) { build(:course) }
            let(:courses) {
              [course1, course3]
            }
            it "does not syncs a provider's courses" do
              perform_enqueued_jobs do
                subject
              end
              expect(sync_stub).to_not have_been_requested
            end
          end
        end
      end
      describe "previous recruitment cycle" do
        let!(:provider) do
          create(
            :provider,
            :previous_recruitment_cycle,
            organisations: [organisation],
            enrichments: [enrichment],
            courses: courses,
          )
        end

        describe "only syncable courses on provider" do
          context "no courses" do
            it "does not syncs a provider's courses" do
              perform_enqueued_jobs do
                subject
              end
              expect(sync_stub).to_not have_been_requested
            end
          end
          context "its fine" do
            let(:courses) {
              [course1, course2]
            }

            it "does not syncs a provider's courses" do
              perform_enqueued_jobs do
                subject
              end
              expect(sync_stub).to_not have_been_requested
            end
          end

          context "mixed" do
            let(:course3) { build(:course) }
            let(:courses) {
              [course1, course3]
            }
            it "does not syncs a provider's courses" do
              perform_enqueued_jobs do
                subject
              end
              expect(sync_stub).to_not have_been_requested
            end
          end
        end
      end
    end
  end
end
