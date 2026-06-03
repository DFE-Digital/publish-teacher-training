# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Steps::VisaSponsorship do
  include_context "add_course_wizard"

  let(:current_step) { :visa_sponsorship }
  let(:provider_code) { provider.provider_code }
  let(:recruitment_cycle_year) { provider.recruitment_cycle_year }
  let(:provider) do
    create(
      :provider,
      :accredited_provider,
      can_sponsor_student_visa: can_sponsor_student_visa,
      recruitment_cycle: find_or_create(:recruitment_cycle),
    )
  end
  let(:can_sponsor_student_visa) { false }
  let(:wizard_step) { wizard.current_step }

  describe "#valid?" do
    it "is valid when can_sponsor_student_visa is true" do
      wizard_step.can_sponsor_student_visa = true

      expect(wizard_step).to be_valid
    end

    it "is valid when can_sponsor_student_visa is false" do
      wizard_step.can_sponsor_student_visa = false

      expect(wizard_step).to be_valid
    end

    it "is not valid when can_sponsor_student_visa is nil" do
      wizard_step.can_sponsor_student_visa = nil

      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors.messages_for(:can_sponsor_student_visa)).to contain_exactly("Select if student visas can be sponsored for this course")
    end
  end

  describe "#question" do
    it "returns the organisation question for university or scitt providers" do
      expect(wizard_step.question).to eq("Can your organisation sponsor Student visas for this course?")
    end

    context "when provider is not university or scitt" do
      let(:provider) do
        create(
          :provider,
          provider_type: :lead_school,
          can_sponsor_student_visa: false,
          recruitment_cycle: find_or_create(:recruitment_cycle),
        )
      end

      it "returns the sponsorship availability question" do
        expect(wizard_step.question).to eq("Is Student visa sponsorship available for this course?")
      end
    end
  end

  describe "#show_recruiting_from_overseas_guidance?" do
    it "returns true for university or scitt providers that cannot sponsor student visas" do
      expect(wizard_step.show_recruiting_from_overseas_guidance?).to be(true)
    end

    context "when provider can sponsor student visas" do
      let(:can_sponsor_student_visa) { true }

      it "returns false" do
        expect(wizard_step.show_recruiting_from_overseas_guidance?).to be(false)
      end
    end

    context "when provider is not university or scitt" do
      let(:provider) do
        create(
          :provider,
          provider_type: :lead_school,
          can_sponsor_student_visa: false,
          recruitment_cycle: find_or_create(:recruitment_cycle),
        )
      end

      it "returns false" do
        expect(wizard_step.show_recruiting_from_overseas_guidance?).to be(false)
      end
    end
  end

  describe "#show_accrediting_provider_inset_text?" do
    let(:provider) do
      create(
        :provider,
        provider_type: :lead_school,
        can_sponsor_student_visa: false,
        recruitment_cycle: find_or_create(:recruitment_cycle),
      )
    end
    let(:accredited_partner) do
      create(
        :accredited_provider,
        can_sponsor_student_visa: accredited_partner_can_sponsor_student_visa,
        recruitment_cycle: provider.recruitment_cycle,
      )
    end
    let(:accredited_partner_can_sponsor_student_visa) { false }
    let(:create_partnership) { true }

    before do
      if create_partnership
        create(:provider_partnership, training_provider: provider, accredited_provider: accredited_partner)
      end
    end

    it "returns true when there is a single accredited partner" do
      expect(wizard_step.show_accrediting_provider_inset_text?).to be(true)
    end

    it "returns the accredited partner name" do
      expect(wizard_step.accrediting_provider_name).to eq(accredited_partner.provider_name)
    end

    it "returns false for accredited partner visa sponsorship capability" do
      expect(wizard_step.accrediting_provider_can_sponsor_student_visa?).to be(false)
    end

    context "when accredited partner can sponsor student visas" do
      let(:accredited_partner_can_sponsor_student_visa) { true }

      it "returns true for accredited partner visa sponsorship capability" do
        expect(wizard_step.accrediting_provider_can_sponsor_student_visa?).to be(true)
      end
    end

    context "when there are multiple accredited partners" do
      before do
        create(:provider_partnership, training_provider: provider, accredited_provider: create(:accredited_provider, recruitment_cycle: provider.recruitment_cycle))
      end

      it "returns false" do
        expect(wizard_step.show_accrediting_provider_inset_text?).to be(false)
      end

      it "returns nil for accrediting provider name" do
        expect(wizard_step.accrediting_provider_name).to be_nil
      end

      it "returns nil for accrediting provider sponsorship capability" do
        expect(wizard_step.accrediting_provider_can_sponsor_student_visa?).to be_nil
      end
    end

    context "when there are no accredited partners" do
      let(:create_partnership) { false }

      it "returns false" do
        expect(wizard_step.show_accrediting_provider_inset_text?).to be(false)
      end

      it "returns nil for accrediting provider name" do
        expect(wizard_step.accrediting_provider_name).to be_nil
      end

      it "returns nil for accrediting provider sponsorship capability" do
        expect(wizard_step.accrediting_provider_can_sponsor_student_visa?).to be_nil
      end
    end
  end

  describe ".permitted_params" do
    it "returns the correct permitted params" do
      expect(described_class.permitted_params).to eq([:can_sponsor_student_visa])
    end
  end
end
