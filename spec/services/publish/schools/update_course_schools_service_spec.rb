# frozen_string_literal: true

require "rails_helper"

module Publish
  module Schools
    RSpec.describe UpdateCourseSchoolsService do
      let(:remodel_cycle_year) { 2026 }
      let(:recruitment_cycle) { create(:recruitment_cycle, year: remodel_cycle_year) }
      let(:site_one) { build(:site, location_name: "Site 1", code: "A") }
      let(:site_two) { build(:site, location_name: "Site 2", code: "B") }
      let(:provider) { create(:provider, recruitment_cycle:, sites: [site_one, site_two]) }
      let(:course) { create(:course, provider:) }
      let(:gias_school_one) { create(:gias_school, urn: site_one.urn) }
      let(:gias_school_two) { create(:gias_school, urn: site_two.urn) }
      let!(:provider_school_one) do
        create(:provider_school, provider:, gias_school: gias_school_one, site_code: site_one.code, uuid: site_one.uuid)
      end
      let!(:provider_school_two) do
        create(:provider_school, provider:, gias_school: gias_school_two, site_code: site_two.code, uuid: site_two.uuid)
      end

      before do
        allow(Settings).to receive(:schools_remodel_cycle_year).and_return(remodel_cycle_year)
      end

      describe ".call_or_enqueue" do
        context "when school_uuids count exceeds ENQUEUE_THRESHOLD" do
          let(:params) { { school_uuids: Array.new(31) { SecureRandom.uuid } } }

          it "enqueues the job" do
            expect(UpdateCourseSchoolsJob).to receive(:perform_async).with(course.id, params.to_h)

            described_class.call_or_enqueue(course:, params:)
          end
        end

        context "when school_uuids count is below or equal to ENQUEUE_THRESHOLD" do
          let(:params) { { school_uuids: [site_one.uuid] } }

          it "runs the service inline" do
            allow(described_class).to receive(:call)

            described_class.call_or_enqueue(course:, params:)

            expect(described_class).to have_received(:call).with(course:, params:)
          end
        end
      end

      describe "#call" do
        subject(:service_call) { described_class.call(course:, params:) }

        context "when the provider is in the schools remodel cycle" do
          let(:params) { { school_uuids: [site_two.uuid] } }

          it "creates relationships in both SiteStatus and Course::School" do
            expect { service_call }
              .to change { course.site_statuses.count }.by(1)
              .and change { course.schools.count }.by(1)

            expect(course.reload.sites).to contain_exactly(site_two)
            expect(course.schools.find_by(provider_school: provider_school_two)).to be_present
          end

          context "when schools_validated is submitted" do
            let(:params) { { school_uuids: [site_two.uuid], schools_validated: "true" } }

            it "persists schools_validated" do
              expect { service_call }
                .to change { course.reload.schools_validated }.to(true)
            end
          end

          context "when the course already has both schools" do
            before do
              course.site_statuses.create!(site: site_one, status: :new_status, publish: :unpublished)
              course.site_statuses.create!(site: site_two, status: :new_status, publish: :unpublished)
              create(:course_school, course:, gias_school: gias_school_one, provider_school: provider_school_one)
              create(:course_school, course:, gias_school: gias_school_two, provider_school: provider_school_two)
            end

            it "removes relationships from both SiteStatus and Course::School" do
              expect { service_call }
                .to change { course.site_statuses.reload.count }.by(-1)
                .and change { course.schools.reload.count }.by(-1)

              expect(course.reload.sites).to contain_exactly(site_two)
              expect(course.schools.where(provider_school: provider_school_one)).to be_empty
            end
          end

          context "when the new-model write fails" do
            before do
              allow(UpdateCourseProviderSchoolsService).to receive(:call)
                .and_raise(UpdateCourseProviderSchoolsService::UnresolvedProviderSchoolsError)
            end

            it "rolls back the legacy SiteStatus write" do
              expect { service_call }.to raise_error(UpdateCourseProviderSchoolsService::UnresolvedProviderSchoolsError)

              expect(course.site_statuses.count).to eq(0)
            end

            it "does not send notifications" do
              FeatureFlag.activate(:course_sites_updated_email_notification)
              expect(NotificationService::CourseSitesUpdated).not_to receive(:call)

              expect { service_call }.to raise_error(UpdateCourseProviderSchoolsService::UnresolvedProviderSchoolsError)
            end
          end
        end

        context "when the provider is after the schools remodel cycle" do
          let(:recruitment_cycle) { create(:recruitment_cycle, year: remodel_cycle_year + 1) }
          let(:params) { { school_uuids: [provider_school_two.uuid] } }

          before do
            course.site_statuses.create!(site: site_one, status: :new_status, publish: :unpublished)
          end

          it "creates only Course::School and does not create SiteStatus" do
            expect { service_call }.to change { course.schools.count }.by(1)

            expect(course.site_statuses.count).to eq(1)
            expect(course.schools.find_by(provider_school: provider_school_two)).to be_present
          end

          context "when schools_validated is submitted" do
            let(:params) { { school_uuids: [provider_school_two.uuid], schools_validated: "true" } }

            it "persists schools_validated" do
              expect { service_call }
                .to change { course.reload.schools_validated }.to(true)
            end

            it "touches the provider so Apply can detect the change" do
              provider.update_columns(changed_at: 2.days.ago)

              expect { service_call }
                .to(change { provider.reload.changed_at })
            end
          end

          context "when school_uuids is omitted" do
            let(:params) { { schools_validated: "true" } }

            before do
              create(:course_school, course:, gias_school: gias_school_one, provider_school: provider_school_one)
            end

            it "keeps the current Course::School rows and persists course attributes" do
              expect { service_call }
                .not_to(change { course.schools.reload.pluck(:provider_school_id) })

              expect(course.reload.schools_validated).to be(true)
            end
          end

          context "when course site update notifications are enabled" do
            before do
              FeatureFlag.activate(:course_sites_updated_email_notification)
              create(:course_school, course:, gias_school: gias_school_one, provider_school: provider_school_one)
            end

            after do
              FeatureFlag.deactivate(:course_sites_updated_email_notification)
            end

            it "sends notifications using provider school names" do
              expect(NotificationService::CourseSitesUpdated).to receive(:call).with(
                course:,
                previous_site_names: [provider_school_one.location_name],
                updated_site_names: [provider_school_two.location_name],
              )

              service_call
            end
          end

          context "when the course is published" do
            let(:course) { create(:course, :published, provider:) }

            before do
              provider.update_columns(changed_at: 2.days.ago)
              course.update_columns(changed_at: 2.days.ago)
            end

            it "touches the provider when a school is added" do
              expect { service_call }
                .to(change { provider.reload.changed_at })
            end

            context "when removing a Course::School" do
              let(:params) { { school_uuids: [] } }

              before do
                create(:course_school, course:, gias_school: gias_school_one, provider_school: provider_school_one)
                provider.update_columns(changed_at: 2.days.ago)
                course.update_columns(changed_at: 2.days.ago)
              end

              it "touches the provider" do
                expect { service_call }
                  .to(change { provider.reload.changed_at })
              end
            end
          end

          context "when a Course::School exists" do
            before do
              create(:course_school, course:, gias_school: gias_school_one, provider_school: provider_school_one)
            end

            it "removes only Course::School and does not change SiteStatus" do
              site_status_count = course.site_statuses.count

              service_call

              expect(course.site_statuses.reload.count).to eq(site_status_count)
              expect(course.schools.where(provider_school: provider_school_one)).to be_empty
              expect(course.schools.find_by(provider_school: provider_school_two)).to be_present
            end
          end

          it "raises when a submitted Provider::School UUID cannot be resolved" do
            expect { described_class.call(course:, params: { school_uuids: [SecureRandom.uuid] }) }
              .to raise_error(UpdateCourseProviderSchoolsService::UnresolvedProviderSchoolsError)
          end
        end
      end
    end
  end
end
