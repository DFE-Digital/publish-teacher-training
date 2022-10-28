# frozen_string_literal: true

require "rails_helper"

module Publish
  describe CourseLocationForm, type: :model do
    let(:params) { {} }
    let(:site1) { build(:site, location_name: "location 1") }
    let(:site2) { build(:site, location_name: "location 2") }
    let(:site_status) { build(:site_status, :new_status, :unpublished, site: site1) }

    let(:provider) { build(:provider, sites: [site1, site2]) }
    let(:course) { create(:course, provider:, site_statuses: [site_status]) }

    subject { described_class.new(course, params:) }

    describe "validations" do
      before { subject.valid? }

      it "validates :site_ids" do
        expect(subject.errors[:site_ids]).to include(I18n.t("activemodel.errors.models.publish/course_location_form.attributes.site_ids.no_locations"))
      end
    end

    describe "#save!" do
      let(:previous_site_names) { course.sites.map(&:location_name) }

      context "different site_ids to course site_ids" do
        let(:params) { { site_ids: provider.site_ids } }

        let(:updated_site_names) { provider.sites.order(:location_name).map(&:location_name) }

        it "calls the course sites updated notification service" do
          expect(NotificationService::CourseSitesUpdated).to receive(:call)
          .with(course:, previous_site_names:, updated_site_names:)
          subject.save!
        end

        context "course is not published" do
          it "sets all site_statuses status to be new_status" do
            subject.save!
            expect(course.reload.site_statuses.pluck(:status)).to match(%w[new_status new_status])
          end
        end

        context "course is published" do
          let(:course) { create(:course, :published, provider:, site_statuses: [site_status]) }
          let(:site_status) { build(:site_status, :running, :published, site: site1) }

          it "sets all site_statuses status to be new_status" do
            subject.save!
            expect(course.reload.site_statuses.pluck(:status)).to match(%w[running running])
          end
        end
      end

      context "same site_ids to course site_ids" do
        let(:params) { { site_ids: course.site_ids } }

        it "does not call the course subjects updated notification service" do
          expect(NotificationService::CourseSitesUpdated).not_to receive(:call)
          subject.save!
        end
      end
    end
  end
end
