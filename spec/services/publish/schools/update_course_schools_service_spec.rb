# frozen_string_literal: true

require "rails_helper"

module Publish
  module Schools
    RSpec.describe UpdateCourseSchoolsService do
      let(:site_one) { build(:site, location_name: "Site 1", code: "A") }
      let(:site_two) { build(:site, location_name: "Site 2", code: "B") }
      let(:provider) { create(:provider, sites: [site_one, site_two]) }
      let(:course) { create(:course, provider:) }
      let(:gias_school_one) { create(:gias_school, name: "Site 1", urn: site_one.urn) }
      let(:gias_school_two) { create(:gias_school, name: "Site 2", urn: site_two.urn) }
      let!(:provider_school_one) do
        create(:provider_school, provider:, gias_school: gias_school_one, site_code: site_one.code, uuid: site_one.uuid)
      end
      let!(:provider_school_two) do
        create(:provider_school, provider:, gias_school: gias_school_two, site_code: site_two.code, uuid: site_two.uuid)
      end

      describe ".call_or_enqueue" do
        context "when the number of school UUIDs exceeds ENQUEUE_THRESHOLD" do
          let(:params) { { school_uuids: Array.new(31) { SecureRandom.uuid } } }

          it "enqueues the update" do
            expect(UpdateCourseSchoolsJob).to receive(:perform_async).with(course.id, params.to_h)

            described_class.call_or_enqueue(course:, params:)
          end
        end

        context "when the number of school UUIDs equals ENQUEUE_THRESHOLD" do
          let(:params) { { school_uuids: Array.new(30) { SecureRandom.uuid } + [""] } }

          it "runs the update inline" do
            allow(described_class).to receive(:call)

            described_class.call_or_enqueue(course:, params:)

            expect(described_class).to have_received(:call).with(course:, params:)
          end
        end

        context "when duplicate and blank UUIDs take the submitted count over ENQUEUE_THRESHOLD" do
          let(:params) { { school_uuids: Array.new(31, provider_school_one.uuid) + [""] } }

          it "counts unique non-blank UUIDs and runs the update inline" do
            allow(described_class).to receive(:call)

            described_class.call_or_enqueue(course:, params:)

            expect(described_class).to have_received(:call).with(course:, params:)
          end
        end

        context "when school UUIDs are nil" do
          let(:params) { { school_uuids: nil } }

          it "runs the update inline" do
            allow(described_class).to receive(:call)

            described_class.call_or_enqueue(course:, params:)

            expect(described_class).to have_received(:call).with(course:, params:)
          end
        end
      end

      describe "#call" do
        subject(:service_call) { described_class.call(course:, params:) }

        let(:params) { { school_uuids: [provider_school_two.uuid] } }

        it "creates both Course::School and legacy SiteStatus relationships" do
          expect { service_call }
            .to change { course.schools.count }.by(1)
            .and change { course.site_statuses.count }.by(1)

          expect(course.reload.schools.find_by(provider_school: provider_school_two)).to be_present
          expect(course.sites).to contain_exactly(site_two)
        end

        context "when the Provider::School GIAS school is closed" do
          let(:gias_school_two) { create(:gias_school, :closed, name: "Site 2", urn: site_two.urn) }

          it "still creates both school relationships" do
            service_call

            expect(course.reload.schools.find_by(provider_school: provider_school_two)).to be_present
            expect(course.sites).to contain_exactly(site_two)
          end
        end

        it "persists course attributes and touches the provider for Apply" do
          params[:schools_validated] = "true"
          provider.update_columns(changed_at: 2.days.ago)
          previous_provider_changed_at = provider.changed_at

          service_call

          expect(course.reload.schools_validated).to be(true)
          expect(provider.reload.changed_at).to be > previous_provider_changed_at
        end

        context "when both school relationships already exist" do
          before do
            attach_school(site_one, provider_school_one)
            attach_school(site_two, provider_school_two)
          end

          it "removes the unselected school from both models" do
            expect { service_call }
              .to change { course.schools.reload.count }.by(-1)
              .and change { course.site_statuses.reload.count }.by(-1)

            expect(course.reload.schools.pluck(:provider_school_id)).to eq([provider_school_two.id])
            expect(course.sites).to contain_exactly(site_two)
          end
        end

        context "when an empty selection is allowed" do
          let(:params) { { school_uuids: [] } }

          before do
            attach_school(site_one, provider_school_one)
          end

          it "removes every school from both models" do
            expect { service_call }
              .to change { course.schools.reload.count }.from(1).to(0)
              .and change { course.site_statuses.reload.count }.from(1).to(0)
          end
        end

        context "when the course is published" do
          let(:course) { create(:course, :published, provider:) }

          before do
            provider.update_columns(changed_at: 2.days.ago)
            course.update_columns(changed_at: 2.days.ago)
          end

          it "touches the provider when a school is added" do
            expect { service_call }.to(change { provider.reload.changed_at })
          end

          context "when a school is removed" do
            let(:params) { { school_uuids: [] } }

            before do
              attach_school(site_one, provider_school_one, status: :running, publish: :published)
              provider.update_columns(changed_at: 2.days.ago)
              course.update_columns(changed_at: 2.days.ago)
            end

            it "touches the provider" do
              expect { service_call }.to(change { provider.reload.changed_at })
            end
          end
        end

        context "when notifications are enabled" do
          before do
            FeatureFlag.activate(:course_sites_updated_email_notification)
            attach_school(site_one, provider_school_one)
          end

          after do
            FeatureFlag.deactivate(:course_sites_updated_email_notification)
          end

          it "sends the new-model school names through the legacy notification interface" do
            expect(NotificationService::CourseSitesUpdated).to receive(:call).with(
              course:,
              previous_site_names: [provider_school_one.location_name],
              updated_site_names: [provider_school_two.location_name],
            )

            service_call
          end
        end

        context "when the Course::School write fails" do
          before do
            allow(UpdateCourseProviderSchoolsService).to receive(:call)
              .and_raise(ActiveRecord::RecordInvalid)
          end

          it "rolls back the legacy write and does not notify" do
            FeatureFlag.activate(:course_sites_updated_email_notification)
            expect(NotificationService::CourseSitesUpdated).not_to receive(:call)

            expect { service_call }.to raise_error(ActiveRecord::RecordInvalid)

            expect(course.site_statuses.count).to eq(0)
          ensure
            FeatureFlag.deactivate(:course_sites_updated_email_notification)
          end
        end

        it "raises inline when a Provider::School UUID cannot be resolved" do
          expect { described_class.call(course:, params: { school_uuids: [SecureRandom.uuid] }) }
            .to raise_error(described_class::UnresolvedProviderSchoolsError)
        end

        it "requires the caller to provide school_uuids" do
          expect { described_class.call(course:, params: { schools_validated: "true" }) }
            .to raise_error(KeyError, /school_uuids/)
        end

        context "when the update is run by the queued job" do
          subject(:service_call) do
            described_class.call(
              course:,
              params:,
              raise_on_missing_provider_schools: false,
            )
          end

          let(:site_three) { create(:site, provider:, location_name: "Site 3") }
          let(:provider_school_three) do
            create(
              :provider_school,
              provider:,
              gias_school: create(:gias_school, name: "Site 3", urn: site_three.urn),
              site_code: site_three.code,
              uuid: site_three.uuid,
            )
          end
          let(:params) { { school_uuids: [provider_school_two.uuid, provider_school_three.uuid] } }

          before do
            attach_school(site_one, provider_school_one)
            provider_school_three.destroy!
          end

          it "skips a school deleted since submission and saves the remaining selection" do
            expect(Rails.logger).to receive(:warn).with(/skipped stale provider_school UUIDs/)

            expect { service_call }.not_to raise_error
            expect(course.reload.schools.pluck(:provider_school_id)).to eq([provider_school_two.id])
            expect(course.sites).to contain_exactly(site_two)
          end

          it "notifies using only the schools that still exist" do
            FeatureFlag.activate(:course_sites_updated_email_notification)
            allow(Rails.logger).to receive(:warn)

            expect(NotificationService::CourseSitesUpdated).to receive(:call).with(
              course:,
              previous_site_names: [provider_school_one.location_name],
              updated_site_names: [provider_school_two.location_name],
            )

            service_call
          ensure
            FeatureFlag.deactivate(:course_sites_updated_email_notification)
          end
        end

        context "when a stale queued school was attached before it was removed" do
          subject(:service_call) do
            described_class.call(
              course:,
              params:,
              raise_on_missing_provider_schools: false,
            )
          end

          let(:site_three) { create(:site, provider:, location_name: "Site 3") }
          let(:provider_school_three) do
            create(
              :provider_school,
              provider:,
              gias_school: create(:gias_school, name: "Site 3", urn: site_three.urn),
              site_code: site_three.code,
              uuid: site_three.uuid,
            )
          end
          let(:params) { { school_uuids: [provider_school_two.uuid, provider_school_three.uuid] } }

          before do
            attach_school(site_three, provider_school_three)
            provider_school_three.destroy!
          end

          it "removes the stale legacy relationship and applies the remaining selection" do
            allow(Rails.logger).to receive(:warn)

            service_call

            expect(course.reload.schools.pluck(:provider_school_id)).to eq([provider_school_two.id])
            expect(course.sites).to contain_exactly(site_two)
          end
        end

        context "when a queued write fails" do
          subject(:service_call) do
            described_class.call(
              course:,
              params:,
              raise_on_missing_provider_schools: false,
            )
          end

          before do
            attach_school(site_one, provider_school_one)
            allow(UpdateCourseProviderSchoolsService).to receive(:call)
              .and_raise(ActiveRecord::RecordInvalid)
          end

          it "still rolls back the dual write" do
            expect { service_call }.to raise_error(ActiveRecord::RecordInvalid)

            expect(course.reload.schools.pluck(:provider_school_id)).to eq([provider_school_one.id])
            expect(course.sites).to contain_exactly(site_one)
          end
        end

        context "when the course save fails after both relationship writes" do
          subject(:service_call) do
            described_class.call(
              course:,
              params:,
              raise_on_missing_provider_schools: false,
            )
          end

          before do
            allow(course).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
          end

          it "rolls back both queued relationship writes" do
            expect { service_call }.to raise_error(ActiveRecord::RecordInvalid)

            expect(course.reload.schools).to be_empty
            expect(course.sites).to be_empty
          end
        end

        context "when a Provider::School has no matching legacy Site" do
          subject(:service_call) do
            described_class.call(
              course:,
              params:,
              raise_on_missing_provider_schools: false,
            )
          end

          let(:provider_school_without_site) do
            create(:provider_school, provider:, gias_school: create(:gias_school))
          end
          let(:params) { { school_uuids: [provider_school_without_site.uuid] } }

          it "raises from a queued update and writes neither relationship" do
            expect { service_call }
              .to raise_error(UpdateCourseSiteStatusesService::UnresolvedSitesError)

            expect(course.reload.schools).to be_empty
            expect(course.site_statuses).to be_empty
          end
        end

        context "when the course belongs to a cycle after the remodel cycle" do
          let(:recruitment_cycle) do
            find_or_create(:recruitment_cycle, year: Settings.schools_remodel_cycle_year + 1)
          end
          let(:provider) { create(:provider, recruitment_cycle:, sites: [site_one, site_two]) }

          it "continues to write both school models" do
            service_call

            expect(course.reload.schools.find_by(provider_school: provider_school_two)).to be_present
            expect(course.sites).to contain_exactly(site_two)
          end
        end
      end

      def attach_school(site, provider_school, status: :new_status, publish: :unpublished)
        course.site_statuses.create!(site:, status:, publish:)
        create(
          :course_school,
          course:,
          provider_school:,
          gias_school: provider_school.gias_school,
        )
      end
    end
  end
end
