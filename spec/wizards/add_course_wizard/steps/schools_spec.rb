# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Steps::Schools do
  include_context "add_course_wizard"

  let(:current_step) { :schools }
  let(:provider_code) { provider.provider_code }
  let(:recruitment_cycle_year) { provider.recruitment_cycle_year }
  let(:school_uuids) { nil }

  let(:provider) { create(:provider, :accredited_provider, recruitment_cycle: find_or_create(:recruitment_cycle)) }
  let!(:school_a) { create_paired_school(provider:, name: "B School", site_code: "A").last }
  let!(:school_b) { create_paired_school(provider:, name: "A School", site_code: "B").last }

  describe "#valid?" do
    subject(:wizard_step) { wizard.current_step }

    it "is valid when at least one school is selected" do
      wizard_step.school_uuids = [school_a.uuid.to_s]

      expect(wizard_step).to be_valid
    end

    it "is not valid when no schools are selected and the provider has several" do
      wizard_step.school_uuids = nil

      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors.messages_for(:school_uuids)).to contain_exactly("Select at least one school")
    end

    context "when the provider has only one school" do
      let!(:school_b) { nil }

      it "auto-selects it and is valid when nothing is submitted" do
        wizard_step.school_uuids = nil

        expect(wizard_step).to be_valid
        expect(wizard_step.school_uuids).to eq([school_a.uuid.to_s])
      end
    end
  end

  describe "#schools" do
    subject(:wizard_step) { wizard.current_step }

    it "returns the provider's schools ordered by GIAS school name" do
      expect(wizard_step.schools).to eq([school_b, school_a])
    end

    # The picker posts uuids, so an unpaired site cannot be rendered.
    it "omits a legacy site with no Provider::School" do
      create(:site, provider:, code: "Z", location_name: "Unpaired School", urn: create(:gias_school).urn)

      expect(wizard_step.schools).to eq([school_b, school_a])
    end
  end

  describe "#collapse_schools?" do
    subject(:wizard_step) { wizard.current_step }

    it "is false when the provider has 20 schools or fewer" do
      expect(wizard_step.collapse_schools?).to be(false)
    end

    context "when the provider has more than 20 schools" do
      before do
        19.times { |index| create_paired_school(provider:, name: "School #{index}", site_code: "S#{index}") }
      end

      it "is true" do
        expect(wizard_step.collapse_schools?).to be(true)
      end
    end
  end

  describe ".permitted_params" do
    it "returns the correct permitted params" do
      expect(described_class.permitted_params).to eq([{ school_uuids: [] }])
    end
  end

  describe "#salaried?" do
    subject(:wizard_step) { wizard.current_step }

    context "when funding type is salary" do
      before do
        state_store.write(funding_type: "salary")
      end

      it "returns true" do
        expect(wizard_step.salaried?).to be(true)
      end
    end

    context "when funding type is apprenticeship" do
      before do
        state_store.write(funding_type: "apprenticeship")
      end

      it "returns true" do
        expect(wizard_step.salaried?).to be(true)
      end
    end

    context "when funding type is fee" do
      before do
        state_store.write(funding_type: "fee")
      end

      it "returns false" do
        expect(wizard_step.salaried?).to be(false)
      end
    end

    context "when qualification is undergraduate degree with qts and funding type is nil" do
      before do
        state_store.write(qualification: "undergraduate_degree_with_qts")
      end

      it "returns true" do
        expect(wizard_step.salaried?).to be(true)
      end
    end
  end
end
