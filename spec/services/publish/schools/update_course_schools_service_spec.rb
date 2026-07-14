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
        context "when school_uuids count exceeds ENQUEUE_THRESHOLD" do
          let(:params) { { school_uuids: Array.new(31) { SecureRandom.uuid } } }

          it "enqueues the job" do
            expect(UpdateCourseSchoolsJob).to receive(:perform_async).with(course.id, params.to_h)
            described_class.call_or_enqueue(course: course, params: params)
          end
        end

        context "when school_uuids count is below or equal to ENQUEUE_THRESHOLD" do
          let(:params) { { school_uuids: provider.sites.map(&:uuid) } }

          it "runs the service inline" do
            service_instance = instance_double(described_class)

            allow(described_class)
              .to receive(:new)
              .with(course: course, params: params)
              .and_return(service_instance)
            allow(UpdateCourseProviderSchoolsService).to receive(:call)

            allow(service_instance).to receive(:call)

            described_class.call_or_enqueue(course: course, params: params)

            expect(described_class)
              .to have_received(:new)
              .with(course: course, params: params)

            expect(service_instance).to have_received(:call)
            expect(UpdateCourseProviderSchoolsService).to have_received(:call).with(course: course, params: params)
          end
        end
      end

      describe "#call" do
        subject(:service_call) { described_class.new(course:, params:).call }

        context "when school_uuids are different from course school UUIDs" do
          let(:params) { { school_uuids: provider.sites.map(&:uuid) } }
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

        context "when school_uuids are the same as course school UUIDs" do
          let(:params) { { school_uuids: course.sites.map(&:uuid) } }

          it "does not call the notification service" do
            expect(NotificationService::CourseSitesUpdated).not_to receive(:call)
            service_call
          end
        end

        # Regression coverage for the QA-reported bug: when a school is
        # unticked, sync_schools suspends (or destroys) its site_status,
        # then apply_publish_status_to_site_statuses runs over the remaining
        # site_statuses. These tests pin down that:
        #   1. Site_statuses suspended/destroyed during sync stay that way.
        #   2. Site_statuses still attached after sync get the right
        #      publish/status applied.
        describe "site_status state after the apply step" do
          let(:provider) { create(:provider, sites: [site_one, site_two]) }
          let(:site_one) { build(:site, location_name: "Site 1") }
          let(:site_two) { build(:site, location_name: "Site 2") }

          context "when unticking a school on a published course" do
            let(:course) do
              create(
                :course,
                :published,
                provider:,
                site_statuses: [
                  build(:site_status, :running, :published, site: site_one),
                  build(:site_status, :running, :published, site: site_two),
                ],
              )
            end
            let(:params) { { school_uuids: [site_two.uuid] } }

            it "destroys the unticked site_status" do
              described_class.new(course:, params:).call

              expect(course.reload.site_statuses.where(site: site_one)).to be_empty
            end

            it "removes the unticked school from course.sites" do
              described_class.new(course:, params:).call

              expect(course.reload.sites.map(&:id)).to contain_exactly(site_two.id)
            end

            it "leaves the kept site_status as :running and :published" do
              described_class.new(course:, params:).call

              site_status = course.reload.site_statuses.find_by!(site: site_two)
              expect(site_status).to be_status_running
              expect(site_status).to be_published_on_ucas
            end
          end

          context "when an existing suspended site_status is on the course" do
            let(:course) do
              create(
                :course,
                :published,
                provider:,
                site_statuses: [
                  build(:site_status, :running, :published, site: site_one),
                  build(:site_status, :suspended, :unpublished, site: site_two),
                ],
              )
            end
            let(:params) { { school_uuids: [site_one.uuid] } }

            it "does not flip the suspended site_status back to running" do
              described_class.new(course:, params:).call

              site_status = course.reload.site_statuses.find_by!(site: site_two)
              expect(site_status).to be_status_suspended
            end

            it "does not flip the suspended site_status back to published" do
              described_class.new(course:, params:).call

              site_status = course.reload.site_statuses.find_by!(site: site_two)
              expect(site_status).to be_unpublished_on_ucas
            end
          end

          context "when an existing discontinued site_status is on the course" do
            let(:course) do
              create(
                :course,
                :published,
                provider:,
                site_statuses: [
                  build(:site_status, :running, :published, site: site_one),
                  build(:site_status, :discontinued, :unpublished, site: site_two),
                ],
              )
            end
            let(:params) { { school_uuids: [site_one.uuid] } }

            it "does not touch the discontinued site_status" do
              described_class.new(course:, params:).call

              site_status = course.reload.site_statuses.find_by!(site: site_two)
              expect(site_status).to be_status_discontinued
              expect(site_status).to be_unpublished_on_ucas
            end
          end

          context "when adding a school to a draft (unpublished) course" do
            let(:course) { create(:course, provider:, site_statuses: []) }
            let(:params) { { school_uuids: [site_one.uuid] } }

            it "the newly attached site_status is :new_status :unpublished" do
              described_class.new(course:, params:).call

              site_status = course.reload.site_statuses.find_by!(site: site_one)
              expect(site_status).to be_status_new_status
              expect(site_status).to be_unpublished_on_ucas
            end
          end
        end
      end
    end
  end
end
