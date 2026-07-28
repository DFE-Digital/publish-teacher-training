# frozen_string_literal: true

require "rails_helper"

module Publish
  module Schools
    RSpec.describe UpdateCourseSiteStatusesService do
      let(:site_one) { build(:site, location_name: "Site 1") }
      let(:site_two) { build(:site, location_name: "Site 2") }
      let(:provider) { create(:provider, sites: [site_one, site_two]) }
      let(:course) { create(:course, provider:) }

      subject(:service_call) { described_class.call(course:, school_uuids:) }

      context "when a school is added to a draft course" do
        let(:school_uuids) { [site_one.uuid] }

        it "creates an unpublished SiteStatus" do
          expect { service_call }.to change { course.site_statuses.count }.by(1)

          site_status = course.reload.site_statuses.find_by!(site: site_one)
          expect(site_status).to be_status_new_status
          expect(site_status).to be_unpublished_on_ucas
        end
      end

      context "when a school is added to a published course" do
        let(:course) { create(:course, :published, provider:) }
        let(:school_uuids) { [site_one.uuid, site_two.uuid] }

        before do
          course.site_statuses.create!(site: site_one, status: :running, publish: :published)
        end

        it "creates a running and published SiteStatus" do
          service_call

          site_status = course.reload.site_statuses.find_by!(site: site_two)
          expect(site_status).to be_status_running
          expect(site_status).to be_published_on_ucas
        end
      end

      context "when a school is removed from a published course" do
        let(:course) { create(:course, :published, provider:) }
        let(:school_uuids) { [site_two.uuid] }

        before do
          course.site_statuses.create!(site: site_one, status: :running, publish: :published)
          course.site_statuses.create!(site: site_two, status: :running, publish: :published)
        end

        it "removes the SiteStatus and leaves the selected school running" do
          service_call

          expect(course.reload.site_statuses.where(site: site_one)).to be_empty
          kept_site_status = course.site_statuses.find_by!(site: site_two)
          expect(kept_site_status).to be_status_running
          expect(kept_site_status).to be_published_on_ucas
        end
      end

      context "when old inactive SiteStatus rows exist" do
        let(:school_uuids) { [site_one.uuid] }

        before do
          course.site_statuses.create!(site: site_one, status: :new_status, publish: :unpublished)
          course.site_statuses.create!(site: site_two, status: :suspended, publish: :unpublished)
          course.site_statuses.create!(site: site_two, status: :discontinued, publish: :unpublished)
        end

        it "does not reactivate them" do
          service_call

          expect(course.reload.site_statuses.where(site: site_two).pluck(:status, :publish))
            .to contain_exactly(%w[suspended unpublished], %w[discontinued unpublished])
        end
      end

      context "when a submitted legacy Site was deleted before the queued update" do
        let(:school_uuids) { [site_one.uuid, site_two.uuid] }

        before do
          course.site_statuses.create!(site: site_one, status: :new_status, publish: :unpublished)
          site_two.discard!
        end

        it "skips the deleted Site without failing" do
          expect { service_call }.not_to raise_error
          expect(course.reload.sites).to contain_exactly(site_one)
        end
      end
    end
  end
end
