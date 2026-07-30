# frozen_string_literal: true

require "rails_helper"

module Publish
  describe CourseSchoolForm, type: :model do
    subject { described_class.new(course, params:) }

    let(:params) { {} }
    let(:provider) { create(:provider) }
    let(:course) { create(:course, provider:) }

    describe "#schools" do
      it "returns the provider's schools ordered by GIAS school name" do
        create_paired_school(provider:, name: "B School", site_code: "A")
        create_paired_school(provider:, name: "A School", site_code: "B")

        form = described_class.new(create(:course, provider:), params: {})

        expect(form.schools.map(&:location_name)).to eq(["A School", "B School"])
      end

      # The picker posts uuids, so a site with no Provider::School cannot be
      # rendered. DataHub::SchoolsRemodelPreflight::Report counts these.
      it "omits a legacy site that has no Provider::School" do
        create_paired_school(provider:, name: "Paired School", site_code: "A")
        create(:site, provider:, code: "Z", location_name: "Unpaired School", urn: create(:gias_school).urn)

        form = described_class.new(create(:course, provider:), params: {})

        expect(form.schools.map(&:location_name)).to eq(["Paired School"])
      end
    end

    describe "#compute_fields" do
      it "pre-selects the schools already attached to the course" do
        _, provider_school = create_paired_school(provider:, name: "A School", site_code: "A")
        create_paired_school(provider:, name: "B School", site_code: "B")
        create(:course_school, course:, gias_school: provider_school.gias_school, provider_school:)

        expect(described_class.new(course, params: {}).school_uuids).to eq([provider_school.uuid])
      end
    end

    describe "#collapse_schools?" do
      it "is false when the provider has 20 schools or fewer" do
        20.times { |index| create_paired_school(provider:, name: "School #{index}", site_code: "S#{index}") }

        expect(described_class.new(create(:course, provider:), params: {}).collapse_schools?).to be(false)
      end

      it "is true when the provider has more than 20 schools" do
        21.times { |index| create_paired_school(provider:, name: "School #{index}", site_code: "S#{index}") }

        expect(described_class.new(create(:course, provider:), params: {}).collapse_schools?).to be(true)
      end
    end

    describe "validations", travel: Find::CycleTimetable.mid_cycle(2026) do
      before { subject.valid? }

      it "validates :school_uuids" do
        expect(subject.errors[:school_uuids])
          .to include(I18n.t("activemodel.errors.models.publish/course_school_form.attributes.school_uuids.no_schools"))
      end

      context "when the course is exempt from needing a school (publish without schools allowed)" do
        let(:course) do
          create(:course, :with_salary, provider:, publish_without_schools_allowed: true)
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
