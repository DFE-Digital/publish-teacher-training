# frozen_string_literal: true

require "rails_helper"

module Publish
  describe CourseSchoolForm, type: :model do
    let(:provider) { create(:provider) }
    let(:provider_school_one) do
      create(:provider_school, provider:, gias_school: create(:gias_school, name: "B School"))
    end
    let(:provider_school_two) do
      create(:provider_school, provider:, gias_school: create(:gias_school, name: "A School"))
    end
    let(:course) { create(:course, provider:) }
    let(:params) { {} }

    subject(:form) { described_class.new(course, params:) }

    describe "#schools" do
      it "returns the provider's Provider::School records ordered by name" do
        provider_school_one
        provider_school_two

        expect(form.schools).to eq([provider_school_two, provider_school_one])
      end

      it "does not return schools that GIAS marks as closed" do
        closed_provider_school = create(
          :provider_school,
          provider:,
          gias_school: create(:gias_school, :closed),
        )

        expect(form.schools).not_to include(closed_provider_school)
      end
    end

    describe "#school_uuids" do
      before do
        create(
          :course_school,
          course:,
          provider_school: provider_school_one,
          gias_school: provider_school_one.gias_school,
        )
      end

      it "uses the selected Provider::School UUIDs" do
        expect(form.school_uuids).to eq([provider_school_one.uuid])
      end
    end

    describe "#collapse_schools?" do
      let(:provider) { create(:provider) }
      let!(:provider_schools) { create_list(:provider_school, school_count, provider:) }

      context "with 20 schools" do
        let(:school_count) { 20 }

        it "is false" do
          expect(form.collapse_schools?).to be(false)
        end
      end

      context "with 21 schools" do
        let(:school_count) { 21 }

        it "is true without loading all the schools" do
          schools = form.schools

          expect(schools).not_to be_loaded
          expect(form.collapse_schools?).to be(true)
          expect(schools).not_to be_loaded
        end
      end
    end

    describe "validations", travel: Find::CycleTimetable.mid_cycle(2026) do
      it "requires a school" do
        expect(form).not_to be_valid
        expect(form.errors[:school_uuids]).to include(
          I18n.t("activemodel.errors.models.publish/course_school_form.attributes.school_uuids.no_schools"),
        )
      end

      it "rejects an unknown UUID" do
        invalid_form = described_class.new(course, params: { school_uuids: [SecureRandom.uuid] })

        expect(invalid_form).not_to be_valid
        expect(invalid_form.errors[:school_uuids]).to include(
          I18n.t("activemodel.errors.models.publish/course_school_form.attributes.school_uuids.school_uuids_invalid"),
        )
      end

      it "rejects a Provider::School UUID belonging to another provider" do
        other_provider_school = create(:provider_school)
        invalid_form = described_class.new(course, params: { school_uuids: [other_provider_school.uuid] })

        expect(invalid_form).not_to be_valid
        expect(invalid_form.errors[:school_uuids]).to include(
          I18n.t("activemodel.errors.models.publish/course_school_form.attributes.school_uuids.school_uuids_invalid"),
        )
      end

      it "accepts a Provider::School UUID belonging to the provider" do
        valid_form = described_class.new(course, params: { school_uuids: [provider_school_one.uuid] })

        expect(valid_form).to be_valid
      end

      it "rejects a Provider::School whose GIAS school is closed" do
        closed_provider_school = create(
          :provider_school,
          provider:,
          gias_school: create(:gias_school, :closed),
        )
        invalid_form = described_class.new(course, params: { school_uuids: [closed_provider_school.uuid] })

        expect(invalid_form).not_to be_valid
        expect(invalid_form.errors[:school_uuids]).to include(
          I18n.t("activemodel.errors.models.publish/course_school_form.attributes.school_uuids.school_uuids_invalid"),
        )
      end

      context "when the course is exempt from needing a school" do
        let(:course) do
          create(
            :course,
            :with_salary,
            provider:,
            publish_without_schools_allowed: true,
          )
        end

        it "does not require a school" do
          expect(form).to be_valid
        end
      end
    end
  end
end
