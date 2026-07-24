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

    before do
      allow(Settings).to receive(:schools_remodel_cycle_year).and_return(2026)
    end

    describe "#schools" do
      it "returns the provider's schools sorted by location name" do
        provider = create(:provider, sites: [build(:site, location_name: "B School"), build(:site, location_name: "A School")])
        form = described_class.new(create(:course, provider:), params: {})

        expect(form.schools.map(&:location_name)).to eq(["A School", "B School"])
      end

      context "when the provider is after the schools remodel cycle" do
        let(:recruitment_cycle) { create(:recruitment_cycle, year: 2027) }
        let(:provider) { create(:provider, recruitment_cycle:) }
        let!(:legacy_site) { create(:site, provider:, location_name: "Legacy Site") }
        let!(:provider_school) { create(:provider_school, provider:, gias_school: create(:gias_school, name: "Provider School")) }
        let(:course) { create(:course, provider:) }
        let(:form) { described_class.new(course, params: {}) }

        it "returns provider schools rather than legacy sites" do
          expect(form.schools).to contain_exactly(provider_school)
        end
      end
    end

    describe "#school_uuids" do
      context "when the provider is after the schools remodel cycle" do
        let(:recruitment_cycle) { create(:recruitment_cycle, year: 2027) }
        let(:provider) { create(:provider, recruitment_cycle:) }
        let(:provider_school) { create(:provider_school, provider:) }
        let(:course) { create(:course, provider:) }

        before do
          create(:course_school, course:, gias_school: provider_school.gias_school, provider_school:)
        end

        it "uses the selected Provider::School UUIDs" do
          form = described_class.new(course, params: {})

          expect(form.school_uuids).to eq([provider_school.uuid])
        end
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

      it "does not load all schools to count whether the list should collapse" do
        provider = create(:provider, sites: build_list(:site, 21))
        form = described_class.new(create(:course, provider:), params: {})
        schools = form.schools

        expect(schools).not_to be_loaded
        expect(form.collapse_schools?).to be(true)
        expect(schools).not_to be_loaded
      end
    end

    describe "validations", travel: Find::CycleTimetable.mid_cycle(2026) do
      before { subject.valid? }

      it "validates :school_uuids" do
        expect(subject.errors[:school_uuids]).to include(I18n.t("activemodel.errors.models.publish/course_school_form.attributes.school_uuids.no_schools"))
      end

      context "when the provider is in the schools remodel cycle" do
        it "rejects a Site UUID that does not belong to the provider" do
          form = described_class.new(course, params: { school_uuids: [SecureRandom.uuid] })

          expect(form).not_to be_valid
          expect(form.errors[:school_uuids]).to include(
            I18n.t("activemodel.errors.models.publish/course_school_form.attributes.school_uuids.school_uuids_invalid"),
          )
        end

        it "rejects a Site UUID belonging to another provider" do
          other_site = create(:site)
          form = described_class.new(course, params: { school_uuids: [other_site.uuid] })

          expect(form).not_to be_valid
          expect(form.errors[:school_uuids]).to include(
            I18n.t("activemodel.errors.models.publish/course_school_form.attributes.school_uuids.school_uuids_invalid"),
          )
        end

        it "accepts a Site UUID that belongs to the provider" do
          form = described_class.new(course, params: { school_uuids: [site2.uuid] })

          expect(form).to be_valid
        end
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

      context "when the provider is after the schools remodel cycle" do
        let(:recruitment_cycle) { create(:recruitment_cycle, year: 2027) }
        let(:provider) { create(:provider, recruitment_cycle:) }
        let(:provider_school) { create(:provider_school, provider:) }
        let(:course) { create(:course, provider:) }

        it "rejects a UUID that does not belong to the provider" do
          form = described_class.new(course, params: { school_uuids: [SecureRandom.uuid] })

          expect(form).not_to be_valid
          expect(form.errors[:school_uuids]).to include(
            I18n.t("activemodel.errors.models.publish/course_school_form.attributes.school_uuids.school_uuids_invalid"),
          )
        end

        it "rejects a Provider::School UUID belonging to another provider" do
          other_provider_school = create(:provider_school)
          form = described_class.new(course, params: { school_uuids: [other_provider_school.uuid] })

          expect(form).not_to be_valid
          expect(form.errors[:school_uuids]).to include(
            I18n.t("activemodel.errors.models.publish/course_school_form.attributes.school_uuids.school_uuids_invalid"),
          )
        end

        it "accepts a Provider::School UUID that belongs to the provider" do
          form = described_class.new(course, params: { school_uuids: [provider_school.uuid] })

          expect(form).to be_valid
        end
      end
    end
  end
end
