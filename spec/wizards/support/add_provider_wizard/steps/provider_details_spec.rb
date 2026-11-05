# frozen_string_literal: true

require "rails_helper"

require_relative "../../../../forms/shared_examples/blank_validation"

RSpec.describe Support::AddProviderWizard::Steps::ProviderDetails, type: :model do
  subject(:wizard_step) { described_class.new(**params, wizard:) }

  let(:recruitment_cycle) { find_or_create(:recruitment_cycle) }
  let(:wizard) do
    Support::AddProviderWizard.new(state_key: "spec", context: { recruitment_cycle_year: recruitment_cycle.year })
  end
  let(:base_params) do
    build(:provider).attributes.symbolize_keys.slice(
      :accredited,
      :accredited_provider_number,
      :provider_code,
      :provider_name,
      :provider_type,
      :ukprn,
      :urn,
    )
  end
  let(:params) { test_params.reverse_merge(base_params) }
  let(:test_params) { {} }

  describe "#accredited?" do
    it "is true when accredited is 1" do
      expect(described_class.new(accredited: "1")).to be_accredited
    end

    it "is false when accredited is 0" do
      expect(described_class.new(accredited: "0")).not_to be_accredited
    end
  end

  describe "#lead_school?" do
    it "is true for a lead school" do
      expect(described_class.new(provider_type: "lead_school")).to be_lead_school
    end

    %w[university scitt].each do |provider_type|
      it "is false for #{provider_type}" do
        expect(described_class.new(provider_type:)).not_to be_lead_school
      end
    end
  end

  describe "validations" do
    it "is valid with the details of a new provider" do
      expect(wizard_step).to be_valid
    end

    it {
      expect(wizard_step).to validate_length_of(:provider_name)
        .is_at_most(100)
        .with_message("Enter a provider name that is 100 characters or fewer")
    }

    it "shows the error messages for invalid provider code length" do
      expect(wizard_step).to validate_length_of(:provider_code)
        .is_equal_to(3)
        .with_message("Provider code should be 3 characters")
    end

    it "shows the error message for invalid provider code format" do
      expect(wizard_step).not_to allow_values("ggg", "11&", "11!", "GGG")
        .for(:provider_code)
        .with_message("Enter a valid provider code (One number, at least, with numbers or uppercase letters)")
    end

    include_examples "blank validation", :provider_name, "Enter a provider name"
    include_examples "blank validation", :provider_code, "Enter a provider code"
    include_examples "blank validation", :ukprn, "Enter a UK provider reference number (UKPRN)"
    include_examples "blank validation", :provider_type, "Select a provider type"

    context "when provider_type is lead_school" do
      let(:test_params) { { provider_type: "lead_school" } }

      include_examples "blank validation", :urn, "Enter a unique reference number (URN)"
    end

    context "when provider_type is lead_school and accredited is false" do
      let(:test_params) { { provider_type: "lead_school", accredited: "0" } }

      include_examples "blank validation", :urn, "Enter a unique reference number (URN)"
    end

    context "when accredited is true" do
      let(:test_params) { { accredited: "1" } }

      include_examples "blank validation", :accredited_provider_number, "Enter an accredited provider number"
    end

    %w[1234 1234567 digit].each do |urn|
      context "when the urn is #{urn}" do
        let(:test_params) { { provider_type: "lead_school", accredited: "0", urn: } }

        it "is not valid" do
          expect(wizard_step).not_to be_valid
          expect(wizard_step.errors[:urn]).to contain_exactly("Enter a valid unique reference number (URN)")
        end
      end
    end

    %w[1234567 123456789 digit].each do |ukprn|
      context "when the ukprn is #{ukprn}" do
        let(:test_params) { { ukprn: } }

        it "is not valid" do
          expect(wizard_step).not_to be_valid
          expect(wizard_step.errors[:ukprn]).to contain_exactly("Enter a valid UK provider reference number (UKPRN) - it must be 8 digits starting with a 1, like 12345678")
        end
      end
    end

    context "when the provider code is used by a provider in the cycle" do
      let(:test_params) { { provider_code: create(:provider, recruitment_cycle:).provider_code } }

      it "is not valid" do
        expect(wizard_step).not_to be_valid
        expect(wizard_step.errors[:provider_code]).to contain_exactly("Provider code already taken")
      end
    end

    context "when the provider code is used by a discarded provider in the cycle" do
      let(:test_params) { { provider_code: create(:provider, :discarded, recruitment_cycle:).provider_code } }

      it "is not valid" do
        expect(wizard_step).not_to be_valid
        expect(wizard_step.errors[:provider_code]).to contain_exactly("Provider code already taken")
      end
    end

    context "when an accredited provider is a lead school" do
      let(:test_params) { { provider_type: "lead_school", accredited: "1" } }

      it "is not valid" do
        expect(wizard_step).not_to be_valid
        expect(wizard_step.errors[:provider_type]).to contain_exactly("Accredited provider cannot be a school")
      end
    end

    shared_examples "accredited provider number validation" do |provider_type, accredited_provider_number, message|
      context "when provider_type is '#{provider_type}' and accredited_provider_number is '#{accredited_provider_number}'" do
        let(:test_params) { { provider_type:, accredited: "1", accredited_provider_number: } }

        it "is not valid" do
          expect(wizard_step).not_to be_valid
          expect(wizard_step.errors[:accredited_provider_number]).to contain_exactly(message)
        end
      end
    end

    [nil, ""].each do |blank_number|
      [nil, "scitt", "university"].each do |provider_type|
        include_examples "accredited provider number validation", provider_type, blank_number, "Enter an accredited provider number"
      end
    end

    %w[a aaaa 12345 54321 abcde 1 5].each do |invalid_number|
      [nil, "scitt", "university"].each do |provider_type|
        include_examples "accredited provider number validation", provider_type, invalid_number, "Enter a valid accredited provider number"
      end
    end

    include_examples "accredited provider number validation", "scitt", "1234", "Enter a valid accredited provider number"
    include_examples "accredited provider number validation", "university", "5432", "Enter a valid accredited provider number"
  end
end
