require "rails_helper"

describe "Provider Publish API v2", type: :request do
  let(:user)         { create(:user) }
  let(:organisation) { create(:organisation, users: [user]) }
  let(:recruitment_cycle) { find_or_create(:recruitment_cycle) }
  let(:provider) do
    create(:provider,
           recruitment_cycle: recruitment_cycle,
           organisations: [organisation])
  end
  let(:payload)      { { email: user.email } }
  let(:token)        { build_jwt :apiv2, payload: payload }
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  describe "PATCH /providers/:provider_code" do
    let(:publish_path) do
      "/api/v2/recruitment_cycles/#{recruitment_cycle.year}" +
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

    context "sync provider with latests enrichments" do
      let(:enrichment) { build(:provider_enrichment, :initial_draft) }
      let(:site1) { create(:site_status, :findable) }
      let(:site2) { create(:site_status, :findable) }
      let(:course1) { build(:course, site_statuses: [site1], subjects: [dfe_subject]) }
      let(:course2) { build(:course, site_statuses: [site2], subjects: [dfe_subject]) }

      let!(:dfe_subject) { find_or_create(:primary_subject, :primary) }

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

      let!(:provider) do
        create(
          :provider,
          organisations: [organisation],
          enrichments: [enrichment],
          courses: courses,
          recruitment_cycle: recruitment_cycle,
        )
      end

      describe "search and compare api sync on provider" do
        context "current recruitment cycle" do
          let(:recruitment_cycle) { find_or_create(:recruitment_cycle) }

          context "no courses" do
            it "does not syncs a provider's courses" do
              perform_enqueued_jobs do
                subject
              end
              expect(sync_stub).to_not have_been_requested
            end
          end
          context "syncable courses" do
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

          context "one syncable and one invalid courses" do
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

        context "next recruitment cycle" do
          let(:recruitment_cycle) { find_or_create(:recruitment_cycle, :next) }

          context "no courses" do
            it "does not syncs a provider's courses" do
              perform_enqueued_jobs do
                subject
              end
              expect(sync_stub).to_not have_been_requested
            end
          end

          context "syncable courses" do
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

          context "one syncable and one invalid courses" do
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

        context "previous recruitment cycle" do
          let(:recruitment_cycle) { find_or_create(:recruitment_cycle, :previous) }

          context "no courses" do
            it "does not syncs a provider's courses" do
              perform_enqueued_jobs do
                subject
              end
              expect(sync_stub).to_not have_been_requested
            end
          end
          context "syncable courses" do
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

          context "one syncable and one invalid courses" do
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
