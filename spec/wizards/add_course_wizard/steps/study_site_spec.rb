# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Steps::StudySites do
  include_context "add_course_wizard"

  let(:current_step) { :study_sites }
  let(:provider_code) { provider.provider_code }
  let(:recruitment_cycle_year) { provider.recruitment_cycle_year }
  let(:study_sites_ids) { nil }

  let(:provider) { create(:provider, :accredited_provider, recruitment_cycle: find_or_create(:recruitment_cycle)) }
  let!(:study_site_b) { create(:site, :study_site, provider:, location_name: "B Study Site") }
  let!(:study_site_z) { create(:site, :study_site, provider:, location_name: "Z Study Site") }
  let!(:study_site_a) { create(:site, :study_site, provider:, location_name: "A Study Site") }

  describe "#valid?" do
    subject(:wizard_step) { wizard.current_step }

    it "is valid when at least one study site is selected" do
      wizard_step.study_sites_ids = %w[1 2]
      expect(wizard_step).to be_valid
    end

    it "is not valid when no study sites are selected" do
      wizard_step.study_sites_ids = nil
      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors.messages_for(:study_sites_ids)).to contain_exactly("Select at least one study site")
    end
  end

  describe "#study_sites" do
    subject(:wizard_step) { wizard.current_step }

    it "returns provider study sites sorted by location name" do
      expect(wizard_step.study_sites).to eq(
        [
          study_site_a,
          study_site_b,
          study_site_z,
        ],
      )
    end
  end

  describe ".permitted_params" do
    it "returns the permitted params" do
      expect(described_class.permitted_params).to eq([{ study_sites_ids: [] }])
    end
  end
end
