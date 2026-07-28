# frozen_string_literal: true

require "rails_helper"

module Publish
  module Schools
    RSpec.describe UpdateCourseProviderSchoolsService do
      let(:site_one) { build(:site, location_name: "Site 1", code: "X") }
      let(:site_two) { build(:site, location_name: "Site 2", code: "Y") }
      let(:provider) { create(:provider, sites: [site_one, site_two]) }
      let(:course) { create(:course, provider:) }
      let(:gias_school_one) { create(:gias_school, urn: site_one.urn) }
      let(:gias_school_two) { create(:gias_school, urn: site_two.urn) }
      let!(:provider_school_one) do
        create(:provider_school, provider:, gias_school: gias_school_one, site_code: site_one.code, uuid: site_one.uuid)
      end
      let!(:provider_school_two) do
        create(:provider_school, provider:, gias_school: gias_school_two, site_code: site_two.code, uuid: site_two.uuid)
      end

      describe "#call" do
        subject(:service_call) { described_class.call(course:, school_uuids:) }

        context "when a provider school is newly attached" do
          let(:school_uuids) { [site_two.uuid] }

          it "creates a Course::School row for the submitted provider school" do
            expect { service_call }.to change { course.schools.count }.by(1)

            added = course.schools.find_by(provider_school: provider_school_two)
            expect(added).to be_present
            expect(added.gias_school).to eq(gias_school_two)
          end
        end

        context "when a provider school UUID is submitted more than once" do
          let(:school_uuids) { [site_two.uuid, site_two.uuid] }

          it "creates one Course::School row for the submitted provider school" do
            expect { service_call }.to change { course.schools.count }.by(1)
            expect(course.schools.where(provider_school: provider_school_two).count).to eq(1)
          end
        end

        context "when a provider school is detached" do
          let(:school_uuids) { [] }

          before do
            create(:course_school, course:, gias_school: gias_school_one, provider_school: provider_school_one)
          end

          it "destroys the Course::School row for the removed provider school" do
            expect { service_call }.to change { course.schools.count }.by(-1)

            expect(course.schools.where(provider_school: provider_school_one)).to be_empty
          end
        end

        context "when the prerequisite provider_school is missing" do
          let(:school_uuids) { [site_two.uuid] }

          before do
            provider_school_two.destroy!
          end

          it "raises" do
            expect { service_call }.to raise_error(described_class::UnresolvedProviderSchoolsError, /no provider_school/)
          end

          context "when missing provider schools should be skipped" do
            subject(:service_call) do
              described_class.call(course:, school_uuids:, raise_on_missing_provider_schools: false)
            end

            it "skips the Course::School write for the missing provider_school" do
              expect { service_call }.not_to raise_error

              expect(course.reload.schools.where(gias_school: gias_school_two)).to be_empty
            end

            it "logs the stale UUID" do
              expect(Rails.logger).to receive(:warn).with(/skipped stale provider_school UUIDs/)

              service_call
            end
          end
        end

        context "when a partially resolved submission should sync the remaining Course::School rows" do
          let(:missing_school_uuid) { SecureRandom.uuid }
          let(:school_uuids) { [provider_school_two.uuid, missing_school_uuid] }

          subject(:service_call) do
            described_class.call(
              course:,
              school_uuids:,
              raise_on_missing_provider_schools: false,
            )
          end

          before do
            create(:course_school, course:, gias_school: gias_school_one, provider_school: provider_school_one)
          end

          it "skips the missing provider school and syncs the resolved selection" do
            expect(Rails.logger).to receive(:warn).with(/skipped stale provider_school UUIDs/)

            expect { service_call }
              .to change { course.schools.reload.pluck(:provider_school_id) }
              .from([provider_school_one.id])
              .to([provider_school_two.id])
          end
        end
      end
    end
  end
end
