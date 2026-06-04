# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Accreditation do
  let(:recruitment_cycle) { find_or_create(:recruitment_cycle) }
  let(:selected_provider_code) { nil }
  let(:accreditation) do
    described_class.new(
      provider:,
      selected_provider_code:,
    )
  end

  describe "#selection_required?" do
    context "when provider is accredited" do
      let(:provider) { create(:provider, :accredited_provider, recruitment_cycle:) }

      it "returns false" do
        expect(accreditation.selection_required?).to be(false)
      end
    end

    context "when school-based provider has one accredited partner" do
      let(:provider) do
        school_provider = create(:provider, provider_type: :lead_school, recruitment_cycle:)
        create(:provider_partnership, training_provider: school_provider, accredited_provider: create(:accredited_provider, recruitment_cycle:))
        school_provider
      end

      it "returns false" do
        expect(accreditation.selection_required?).to be(false)
      end
    end

    context "when school-based provider has multiple accredited partners" do
      let(:provider) do
        school_provider = create(:provider, provider_type: :lead_school, recruitment_cycle:)
        create(:provider_partnership, training_provider: school_provider, accredited_provider: create(:accredited_provider, recruitment_cycle:))
        create(:provider_partnership, training_provider: school_provider, accredited_provider: create(:accredited_provider, recruitment_cycle:))
        school_provider
      end

      it "returns true" do
        expect(accreditation.selection_required?).to be(true)
      end
    end
  end

  describe "#accrediting_provider" do
    context "when provider is accredited" do
      let(:provider) { create(:provider, :accredited_provider, recruitment_cycle:) }

      it "returns nil" do
        expect(accreditation.accrediting_provider).to be_nil
      end
    end

    context "when school-based provider has one accredited partner" do
      let(:accredited_partner) { create(:accredited_provider, recruitment_cycle:) }
      let(:provider) do
        school_provider = create(:provider, provider_type: :lead_school, recruitment_cycle:)
        create(:provider_partnership, training_provider: school_provider, accredited_provider: accredited_partner)
        school_provider
      end

      it "returns the only accredited partner" do
        expect(accreditation.accrediting_provider).to eq(accredited_partner)
      end
    end

    context "when school-based provider has multiple accredited partners" do
      let(:accredited_partner_one) { create(:accredited_provider, provider_name: "Middlesex University", recruitment_cycle:) }
      let(:accredited_partner_two) { create(:accredited_provider, provider_name: "University of Hertfordshire", recruitment_cycle:) }
      let(:provider) do
        school_provider = create(:provider, provider_type: :lead_school, recruitment_cycle:)
        create(:provider_partnership, training_provider: school_provider, accredited_provider: accredited_partner_one)
        create(:provider_partnership, training_provider: school_provider, accredited_provider: accredited_partner_two)
        school_provider
      end

      context "when selected_provider_code is present" do
        let(:selected_provider_code) { accredited_partner_two.provider_code }

        it "returns the selected partner" do
          expect(accreditation.accrediting_provider).to eq(accredited_partner_two)
        end
      end

      context "when selected_provider_code is blank" do
        it "returns nil" do
          expect(accreditation.accrediting_provider).to be_nil
        end
      end
    end
  end

  describe "#partners" do
    let(:provider) do
      school_provider = create(:provider, provider_type: :lead_school, recruitment_cycle:)
      create(:provider_partnership, training_provider: school_provider, accredited_provider: accredited_partner_two)
      create(:provider_partnership, training_provider: school_provider, accredited_provider: accredited_partner_one)
      school_provider
    end
    let(:accredited_partner_one) { create(:accredited_provider, provider_name: "Middlesex University", recruitment_cycle:) }
    let(:accredited_partner_two) { create(:accredited_provider, provider_name: "University of Hertfordshire", recruitment_cycle:) }

    it "returns partners sorted by provider name" do
      expect(accreditation.partners).to eq([accredited_partner_one, accredited_partner_two])
    end
  end
end
