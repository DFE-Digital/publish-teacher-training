require "rails_helper"

module Publish
  module Schools
    RSpec.describe UpdateCourseSchoolsService do
      let(:site_one) { build(:site, location_name: "location 1") }
      let(:site_two) { build(:site, location_name: "location 2") }
      let(:site_status) { build(:site_status, :new_status, :unpublished, site: site_one) }
      let(:provider) { build(:provider, sites: [site_one, site_two]) }
      let(:course) { create(:course, provider:, site_statuses: [site_status]) }
      let(:previous_site_names) { course.sites.map(&:location_name) }

      describe ".call_or_enqueue" do
        context "when site_ids count exceeds ENQUEUE_THRESHOLD" do
          let(:params) { { site_ids: Array.new(31) { SecureRandom.uuid } } }

          it "enqueues the job" do
            expect(UpdateCourseSchoolsJob).to receive(:perform_async).with(course.id, params.to_h)
            described_class.call_or_enqueue(course: course, params: params)
          end
        end

        context "when site_ids count is below or equal to ENQUEUE_THRESHOLD" do
          let(:params) { { site_ids: provider.site_ids } }

          it "runs the service inline" do
            service_instance = instance_double(described_class)

            allow(described_class)
              .to receive(:new)
              .with(course: course, params: params)
              .and_return(service_instance)

            allow(service_instance).to receive(:call)

            described_class.call_or_enqueue(course: course, params: params)

            expect(described_class)
              .to have_received(:new)
              .with(course: course, params: params)

            expect(service_instance).to have_received(:call)
          end
        end
      end

      describe "#call" do
        subject(:service_call) { described_class.new(course:, params:).call }

        context "when site_ids are different from course.site_ids" do
          let(:params) { { site_ids: provider.site_ids } }
          let(:updated_site_names) { provider.sites.order(:location_name).map(&:location_name) }

          context "when feature flag is enabled" do
            before { FeatureFlag.activate(:course_sites_updated_email_notification) }

            it "calls the CourseSitesUpdated notification service" do
              expect(NotificationService::CourseSitesUpdated).to receive(:call)
                .with(course: course, previous_site_names: previous_site_names, updated_site_names: updated_site_names)
              service_call
            end
          end

          context "when feature flag is disabled" do
            before { FeatureFlag.deactivate(:course_sites_updated_email_notification) }

            it "does not call the notification service" do
              expect(NotificationService::CourseSitesUpdated).not_to receive(:call)
              service_call
            end
          end

          context "when course is not published" do
            it "sets all site_statuses to new_status" do
              service_call
              expect(course.reload.site_statuses.pluck(:status)).to match(%w[new_status new_status])
            end
          end

          context "when course is published" do
            let(:course) { create(:course, :published, provider:, site_statuses: [site_status]) }
            let(:site_status) { build(:site_status, :running, :published, site: site_one) }

            it "sets all site_statuses to running" do
              service_call
              expect(course.reload.site_statuses.pluck(:status)).to match(%w[running running])
            end
          end
        end

        context "when site_ids are the same as course.site_ids" do
          let(:params) { { site_ids: course.site_ids } }

          it "does not call the notification service" do
            expect(NotificationService::CourseSitesUpdated).not_to receive(:call)
            service_call
          end
        end

        context "dual-write to Course::School" do
          let(:gias_school_one) { create(:gias_school, urn: site_one.urn) }
          let(:gias_school_two) { create(:gias_school, urn: site_two.urn) }

          before do
            # Persist sites so they have IDs / URNs present in the DB
            provider.save!
            create(:provider_school, provider:, gias_school: gias_school_one, site_code: "X")
            create(:provider_school, provider:, gias_school: gias_school_two, site_code: "Y")
          end

          context "when a site is newly attached" do
            let(:params) { { site_ids: [site_one.id, site_two.id] } }

            it "creates a Course::School row for the newly attached site" do
              expect {
                described_class.new(course:, params:).call
              }.to change { course.schools.count }.by(1)

              added = course.schools.find_by(gias_school: gias_school_two)
              expect(added).to be_present
              expect(added.site_code).to eq("Y")
            end
          end

          context "when a site is detached" do
            let(:params) { { site_ids: [] } }

            before do
              create(:course_school, course:, gias_school: gias_school_one, site_code: "X")
            end

            it "destroys the Course::School row for the detached site" do
              expect {
                described_class.new(course:, params:).call
              }.to change { course.schools.count }.by(-1)

              expect(course.schools.where(gias_school: gias_school_one)).to be_empty
            end
          end

          context "when the new-model write fails" do
            let(:params) { { site_ids: [site_one.id, site_two.id] } }

            before do
              # Destroy the prerequisite provider_school so Creator raises
              Provider::School.where(provider:, gias_school: gias_school_two).destroy_all
            end

            it "rolls back the legacy SiteStatus write" do
              previous_site_status_count = course.site_statuses.count

              expect {
                described_class.new(course:, params:).call
              }.to raise_error(ActiveRecord::RecordNotFound)

              expect(course.reload.site_statuses.count).to eq(previous_site_status_count)
            end
          end
        end
      end
    end
  end
end
