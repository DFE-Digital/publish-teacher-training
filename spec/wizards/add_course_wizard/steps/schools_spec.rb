# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Steps::Schools do
  include_context "add_course_wizard"

  let(:current_step) { :schools }
  let(:provider_code) { provider.provider_code }
  let(:recruitment_cycle_year) { provider.recruitment_cycle_year }
  let(:current_step_params) { { site_ids: } }
  let(:site_ids) { nil }

  let(:provider) { create(:provider, :accredited_provider, recruitment_cycle: find_or_create(:recruitment_cycle)) }
  let!(:site_a) { create(:site, provider:, location_name: "B School") }
  let!(:site_b) { create(:site, provider:, location_name: "A School") }

  describe "#valid?" do
    subject(:wizard_step) { wizard.current_step }

    it "is valid when at least one site is selected" do
      wizard_step.site_ids = [site_a.id.to_s]

      expect(wizard_step).to be_valid
    end

    it "is not valid when no sites are selected and provider has multiple sites" do
      wizard_step.site_ids = nil

      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors.messages_for(:site_ids)).to contain_exactly("Select at least one school")
    end

    context "when provider has only one site" do
      let!(:site_b) { nil }

      it "auto-selects the only site and is valid when no site is submitted" do
        wizard_step.site_ids = nil

        expect(wizard_step).to be_valid
        expect(wizard_step.site_ids).to eq([site_a.id.to_s])
      end
    end
  end

  describe "#sites" do
    subject(:wizard_step) { wizard.current_step }

    it "returns provider sites sorted by location name" do
      expect(wizard_step.sites).to eq(
        [
          site_b,
          site_a,
        ],
      )
    end

    it "uses provider/recruitment cycle from the wizard when available" do
      wizard.provider = provider
      wizard.recruitment_cycle = provider.recruitment_cycle

      expect(RecruitmentCycle).not_to receive(:find_by!)

      wizard_step.sites
    end
  end

  describe ".permitted_params" do
    it "returns the correct permitted params" do
      expect(described_class.permitted_params).to eq([{ site_ids: [] }])
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
