# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Steps::AccreditedProvider do
  include_context "add_course_wizard"

  let(:current_step) { :accredited_provider }
  let(:provider) do
    school_provider = create(:provider, provider_type: :lead_school, provider_code:, recruitment_cycle:)
    create(:provider_partnership, training_provider: school_provider, accredited_provider: accredited_partner_one)
    create(:provider_partnership, training_provider: school_provider, accredited_provider: accredited_partner_two)
    school_provider
  end
  let(:accredited_partner_one) { create(:accredited_provider, provider_name: "Middlesex University", recruitment_cycle:) }
  let(:accredited_partner_two) { create(:accredited_provider, provider_name: "University of Hertfordshire", recruitment_cycle:) }
  let(:wizard_step) { wizard.current_step }

  describe "#valid?" do
    it "is valid when accredited_provider_code is present" do
      wizard_step.accredited_provider_code = accredited_partner_one.provider_code

      expect(wizard_step).to be_valid
    end

    it "is not valid when accredited_provider_code is blank" do
      wizard_step.accredited_provider_code = nil

      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors.messages_for(:accredited_provider_code)).to contain_exactly("Select an accredited provider")
    end
  end

  describe "#accredited_partners" do
    it "returns accredited partners sorted by provider name" do
      expect(wizard_step.accredited_partners).to eq([accredited_partner_one, accredited_partner_two])
    end
  end

  describe ".permitted_params" do
    it "returns the correct permitted params" do
      expect(described_class.permitted_params).to eq([:accredited_provider_code])
    end
  end
end
