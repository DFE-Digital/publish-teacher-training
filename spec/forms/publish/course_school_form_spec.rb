# frozen_string_literal: true

require "rails_helper"

module Publish
  describe CourseSchoolForm, type: :model do
    let(:params) { {} }
    let(:site1) { build(:site, location_name: "location 1") }
    let(:site2) { build(:site, location_name: "location 2") }
    let(:site_status) { build(:site_status, :new_status, :unpublished, site: site1) }

    let(:provider) { build(:provider, sites: [site1, site2]) }
    let(:course) { create(:course, provider:, site_statuses: [site_status]) }

    subject { described_class.new(course, params:) }

    describe "validations", travel: Find::CycleTimetable.mid_cycle(2026) do
      before { subject.valid? }

      it "validates :site_ids" do
        expect(subject.errors[:site_ids]).to include(I18n.t("activemodel.errors.models.publish/course_school_form.attributes.site_ids.no_schools"))
      end
    end
  end
end
