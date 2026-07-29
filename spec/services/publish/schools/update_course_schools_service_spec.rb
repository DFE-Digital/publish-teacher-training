require "rails_helper"

module Publish
  module Schools
    RSpec.describe UpdateCourseSchoolsService do
      let(:provider) { create(:provider) }
      let(:pair_one) { paired_school(name: "location 1", site_code: "X") }
      let(:pair_two) { paired_school(name: "location 2", site_code: "Y") }
      let(:site_one) { pair_one.first }
      let(:site_two) { pair_two.first }
      let(:school_one) { pair_one.last }
      let(:school_two) { pair_two.last }
      let(:course) { create(:course, provider:) }

      # provider_school.uuid is a copy of site.uuid while legacy sites are
      # still written, which is what lets the uuid the picker posts resolve
      # back to a SiteStatus.
      def paired_school(name:, site_code:, provider: self.provider)
        uuid = SecureRandom.uuid
        gias_school = create(:gias_school, name:)
        site = create(:site, provider:, uuid:, code: site_code, urn: gias_school.urn, location_name: name)
        provider_school = create(:provider_school, provider:, gias_school:, site_code:, uuid:)
        [site, provider_school]
      end

      def attach!(course, site, provider_school, status: :new_status, publish: :unpublished)
        create(:site_status, status, publish, course:, site:)
        create(:course_school, course:, gias_school: provider_school.gias_school, provider_school:)
      end

      describe ".call_or_enqueue" do
        context "when the school count exceeds ENQUEUE_THRESHOLD" do
          let(:params) { { school_uuids: Array.new(31) { SecureRandom.uuid } } }

          it "enqueues the job" do
            expect(UpdateCourseSchoolsJob).to receive(:perform_async).with(course.id, params.to_h)

            described_class.call_or_enqueue(course:, params:)
          end
        end

        context "when the school count is below ENQUEUE_THRESHOLD" do
          let(:params) { { school_uuids: [school_one.uuid] } }

          it "runs the service inline" do
            service_instance = instance_double(described_class)
            allow(described_class).to receive(:new).with(course:, params:).and_return(service_instance)
            allow(service_instance).to receive(:call)

            described_class.call_or_enqueue(course:, params:)

            expect(service_instance).to have_received(:call)
          end
        end
      end

      # The picker and any Sidekiq job enqueued by the previous release still
      # speak site_ids. Without this the service would see no school_uuids,
      # compute an empty diff and silently discard the update — and by
      # definition the enqueued ones are the largest.
      describe "legacy site_ids payloads" do
        it "converts site ids to the paired provider school uuids" do
          attach!(course, site_one, school_one)

          expect {
            described_class.new(course:, params: { site_ids: [site_one.id, site_two.id] }).call
          }.to change { course.schools.count }.by(1)

          expect(course.schools.reload.map(&:provider_school)).to contain_exactly(school_one, school_two)
        end

        it "treats an empty site_ids list as detach everything" do
          attach!(course, site_one, school_one)

          expect {
            described_class.new(course:, params: { site_ids: [] }).call
          }.to change { course.schools.count }.by(-1)
        end

        it "accepts the string keys a Sidekiq payload arrives with" do
          expect {
            described_class.new(course:, params: { "site_ids" => [site_one.id.to_s] }).call
          }.to change { course.schools.count }.by(1)
        end

        it "enqueues the converted payload, so the job never sees site_ids" do
          stub_const("#{described_class}::ENQUEUE_THRESHOLD", 1)

          expect(UpdateCourseSchoolsJob).to receive(:perform_async)
            .with(course.id, { school_uuids: [school_one.uuid, school_two.uuid] })

          described_class.call_or_enqueue(course:, params: { site_ids: [site_one.id, site_two.id] })
        end

        it "ignores site_ids when school_uuids is also present" do
          expect {
            described_class.new(course:, params: { site_ids: [site_one.id], school_uuids: [school_two.uuid] }).call
          }.to change { course.schools.count }.by(1)

          expect(course.schools.reload.map(&:provider_school)).to contain_exactly(school_two)
        end
      end

      describe "#call" do
        subject(:service_call) { described_class.new(course:, params:).call }

        context "when a school is newly attached" do
          let(:params) { { school_uuids: [school_one.uuid, school_two.uuid] } }

          before { attach!(course, site_one, school_one) }

          it "creates the Course::School row" do
            expect { service_call }.to change { course.schools.count }.by(1)

            expect(course.schools.reload.map(&:provider_school)).to contain_exactly(school_one, school_two)
          end

          it "creates the legacy site_status" do
            service_call

            expect(course.reload.sites).to include(site_two)
          end
        end

        context "when a school is detached" do
          let(:params) { { school_uuids: [school_one.uuid] } }

          before do
            attach!(course, site_one, school_one)
            attach!(course, site_two, school_two)
          end

          it "destroys the Course::School row" do
            expect { service_call }.to change { course.schools.count }.by(-1)

            expect(course.schools.reload.map(&:provider_school)).to contain_exactly(school_one)
          end

          it "destroys the legacy site_status" do
            service_call

            expect(course.reload.site_statuses.where(site: site_two)).to be_empty
          end
        end

        context "when the submitted schools match what is attached" do
          let(:params) { { school_uuids: [school_one.uuid] } }

          before { attach!(course, site_one, school_one) }

          it "changes nothing" do
            expect { service_call }.not_to(change { course.schools.count })
          end

          it "does not notify" do
            expect(NotificationService::CourseSitesUpdated).not_to receive(:call)

            service_call
          end
        end

        # A uuid the picker never rendered cannot be resolved, so it is ignored
        # rather than blowing up a whole submission.
        context "when an unknown uuid is submitted" do
          let(:params) { { school_uuids: [school_one.uuid, SecureRandom.uuid] } }

          it "attaches the schools it can resolve" do
            expect { service_call }.to change { course.schools.count }.by(1)
          end
        end

        # The picker cannot render an attachment with no Provider::School, so
        # the service must not treat it as a removal. Leaving it attached is
        # the whole point of the identity's union rule.
        context "when the course has an attachment the picker cannot represent" do
          let(:orphan_site) { create(:site, provider:, code: "Z", urn: create(:gias_school).urn) }
          let(:params) { { school_uuids: [school_one.uuid] } }

          before do
            attach!(course, site_one, school_one)
            create(:site_status, :running, course:, site: orphan_site)
          end

          it "leaves its site_status alone" do
            service_call

            expect(course.reload.site_statuses.where(site: orphan_site)).not_to be_empty
          end
        end

        context "when the Provider::School has no kept legacy site" do
          let(:params) { { school_uuids: [school_one.uuid, school_two.uuid] } }

          before do
            attach!(course, site_one, school_one)
            site_two.discard!
          end

          # Course.findable joins site_statuses, so writing the new model
          # without the legacy row would publish a course Find cannot return.
          it "raises rather than creating a course Find cannot surface" do
            expect { service_call }.to raise_error(described_class::MissingLegacySite)
          end

          it "rolls the whole update back" do
            expect { service_call }.to raise_error(described_class::MissingLegacySite)
              .and(not_change { course.schools.reload.count })
          end
        end

        context "when detaching a school whose legacy site has gone" do
          let(:params) { { school_uuids: [] } }

          before do
            attach!(course, site_one, school_one)
            site_one.discard!
          end

          it "still removes the Course::School row rather than blocking the user" do
            expect { service_call }.to change { course.schools.count }.by(-1)
          end

          it "logs the orphaned site_status" do
            allow(Rails.logger).to receive(:warn)

            service_call

            expect(Rails.logger).to have_received(:warn).with(/no kept site/)
          end
        end

        context "after the schools remodel cycle" do
          let(:recruitment_cycle) { create(:recruitment_cycle, year: Settings.schools_remodel_cycle_year + 1) }
          let(:provider) { create(:provider, recruitment_cycle:) }
          let(:params) { { school_uuids: [school_one.uuid] } }

          it "writes only the new model" do
            expect { service_call }.to change { course.schools.count }.by(1)

            expect(course.reload.site_statuses).to be_empty
          end
        end

        describe "publish status applied to site_statuses" do
          context "when the course is not published" do
            let(:params) { { school_uuids: [school_one.uuid, school_two.uuid] } }

            before { attach!(course, site_one, school_one) }

            it "leaves everything as new_status" do
              service_call

              expect(course.reload.site_statuses.pluck(:status)).to match(%w[new_status new_status])
            end
          end

          context "when the course is published" do
            let(:course) { create(:course, :published, provider:) }
            let(:params) { { school_uuids: [school_one.uuid, school_two.uuid] } }

            before { attach!(course, site_one, school_one, status: :running, publish: :published) }

            it "sets all site_statuses to running" do
              service_call

              expect(course.reload.site_statuses.pluck(:status)).to match(%w[running running])
            end
          end

          context "when unticking a school on a published course" do
            let(:course) { create(:course, :published, provider:) }
            let(:params) { { school_uuids: [school_two.uuid] } }

            before do
              attach!(course, site_one, school_one, status: :running, publish: :published)
              attach!(course, site_two, school_two, status: :running, publish: :published)
            end

            it "destroys the unticked site_status" do
              service_call

              expect(course.reload.site_statuses.where(site: site_one)).to be_empty
            end

            it "leaves the kept site_status running and published" do
              service_call

              site_status = course.reload.site_statuses.find_by!(site: site_two)
              expect(site_status).to be_status_running
              expect(site_status).to be_published_on_ucas
            end
          end

          context "when a suspended site_status is on the course" do
            let(:course) { create(:course, :published, provider:) }
            let(:params) { { school_uuids: [school_one.uuid] } }

            before do
              attach!(course, site_one, school_one, status: :running, publish: :published)
              create(:site_status, :suspended, :unpublished, course:, site: site_two)
            end

            it "does not flip it back to running" do
              service_call

              expect(course.reload.site_statuses.find_by!(site: site_two)).to be_status_suspended
            end
          end
        end

        describe "notifications" do
          let(:params) { { school_uuids: [school_one.uuid, school_two.uuid] } }

          before { attach!(course, site_one, school_one) }

          context "when the feature flag is enabled" do
            before { FeatureFlag.activate(:course_sites_updated_email_notification) }

            it "reports the school names before and after" do
              expect(NotificationService::CourseSitesUpdated).to receive(:call).with(
                course:,
                previous_site_names: ["location 1"],
                updated_site_names: ["location 1", "location 2"],
              )

              service_call
            end
          end

          context "when the feature flag is disabled" do
            before { FeatureFlag.deactivate(:course_sites_updated_email_notification) }

            it "does not notify" do
              expect(NotificationService::CourseSitesUpdated).not_to receive(:call)

              service_call
            end
          end
        end

        describe "other course attributes" do
          let(:params) { { school_uuids: [school_one.uuid], schools_validated: "true" } }

          it "are assigned alongside the schools" do
            expect { service_call }.to change { course.reload.schools_validated }.to(true)
          end
        end
      end
    end
  end
end
