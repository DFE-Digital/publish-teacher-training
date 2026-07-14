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

    describe "#sites" do
      it "returns the provider's schools sorted by location name" do
        provider = create(:provider, sites: [build(:site, location_name: "B School"), build(:site, location_name: "A School")])
        form = described_class.new(create(:course, provider:), params: {})

        expect(form.sites.map(&:location_name)).to eq(["A School", "B School"])
      end
    end

    describe "#collapse_schools?" do
      it "is false when the provider has 20 schools or fewer" do
        provider = create(:provider, sites: build_list(:site, 20))
        form = described_class.new(create(:course, provider:), params: {})

        expect(form.collapse_schools?).to be(false)
      end

      it "is true when the provider has more than 20 schools" do
        provider = create(:provider, sites: build_list(:site, 21))
        form = described_class.new(create(:course, provider:), params: {})

        expect(form.collapse_schools?).to be(true)
      end
    end

    describe "validations", travel: Find::CycleTimetable.mid_cycle(2026) do
      before { subject.valid? }

      it "validates :school_uuids" do
        expect(subject.errors[:school_uuids]).to include(I18n.t("activemodel.errors.models.publish/course_school_form.attributes.school_uuids.no_schools"))
      end

      context "when the course is exempt from needing a school (publish without schools allowed)" do
        let(:course) do
          create(:course, :with_salary, provider:, site_statuses: [site_status], publish_without_schools_allowed: true)
        end

        before { FeatureFlag.activate(:course_publishing_uses_new_school_model) }

        it "does not require at least one school" do
          subject.valid?

          expect(subject.errors[:school_uuids]).to be_empty
        end

        context "when the new school model flag is OFF" do
          # Support has approved this course to publish without schools; that
          # decision should hold regardless of the course_publishing_uses_new_school_model
          # rollout flag. (Flag deliberately NOT activated here.)
          before { FeatureFlag.deactivate(:course_publishing_uses_new_school_model) }

          it "still does not require at least one school" do
            subject.valid?

            expect(subject.errors[:school_uuids]).to be_empty
          end
        end
      end
    end
  end
end
