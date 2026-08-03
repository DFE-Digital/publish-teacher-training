# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Steps::Schools do
  include_context "add_course_wizard"

  let(:current_step) { :schools }
  let(:provider_code) { provider.provider_code }
  let(:recruitment_cycle_year) { Settings.schools_remodel_cycle_year }
  let(:school_uuids) { nil }

  let(:provider) { create(:provider, :accredited_provider, recruitment_cycle:) }

  let!(:site_a) { create(:site, provider:, location_name: "B School") }
  let!(:site_b) { create(:site, provider:, location_name: "A School") }

  describe "#valid?" do
    subject(:wizard_step) { wizard.current_step }

    it "is valid when at least one school UUID is selected" do
      wizard_step.school_uuids = [site_a.uuid]

      expect(wizard_step).to be_valid
    end

    it "is not valid when no schools are selected and provider has multiple schools" do
      wizard_step.school_uuids = nil

      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors.messages_for(:school_uuids)).to contain_exactly("Select at least one school")
    end

    it "is not valid when a school UUID cannot be resolved" do
      wizard_step.school_uuids = [SecureRandom.uuid]

      expect(Rails.logger).to receive(:warn).with(/unrecognised school UUIDs/)

      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors.messages_for(:school_uuids)).to contain_exactly(
        "Some of the schools you selected were not recognised. Try again or get in touch with support at becomingateacher@digital.education.gov.uk",
      )
    end

    it "is not valid when a school UUID is not a UUID" do
      wizard_step.school_uuids = [site_a.id.to_s]

      expect(Rails.logger).to receive(:warn).with(/unrecognised school UUIDs/)

      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors.messages_for(:school_uuids)).to contain_exactly(
        "Some of the schools you selected were not recognised. Try again or get in touch with support at becomingateacher@digital.education.gov.uk",
      )
    end

    context "when provider has only one site" do
      let!(:site_b) { nil }

      it "auto-selects the only site and is valid when no site is submitted" do
        wizard_step.school_uuids = nil

        expect(wizard_step).to be_valid
        expect(wizard_step.school_uuids).to eq([site_a.uuid])
      end
    end
  end

  describe "#schools" do
    subject(:wizard_step) { wizard.current_step }

    it "returns provider sites sorted by location name" do
      expect(wizard_step.schools).to eq(
        [
          site_b,
          site_a,
        ],
      )
    end
  end

  describe "#collapse_schools?" do
    subject(:wizard_step) { wizard.current_step }

    it "is false when the provider has 20 schools or fewer" do
      expect(wizard_step.collapse_schools?).to be(false)
    end

    context "when the provider has more than 20 schools" do
      before { create_list(:site, 19, provider:) }

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
