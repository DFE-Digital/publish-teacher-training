# frozen_string_literal: true

require "rails_helper"

require_relative "../../../../forms/shared_examples/blank_validation"

RSpec.describe Support::AddProviderWizard::Steps::ContactDetails, type: :model do
  subject(:wizard_step) { described_class.new(**params) }

  let(:params) do
    build(:provider).attributes.symbolize_keys.slice(
      :email,
      :telephone,
      :website,
      :address1,
      :address2,
      :address3,
      :town,
      :address4,
      :postcode,
    )
  end

  describe "#full_address" do
    let(:params) do
      {
        address1: "2431 Collins Tunnel",
        address2: "Willow Village",
        address3: "OHara Row",
        town: "Yundtside",
        address4: "Idaho",
        postcode: "UN5 8BA",
      }
    end

    it "joins the address lines" do
      expect(wizard_step.full_address).to eql(params.values.join("<br> "))
    end

    it "escapes HTML in the address lines" do
      wizard_step.address1 = "<b>1 Street</b>"

      expect(wizard_step.full_address).to start_with("&lt;b&gt;1 Street&lt;/b&gt;<br> ")
    end
  end

  describe "validations" do
    it "is valid with the contact details of a provider" do
      expect(wizard_step).to be_valid
    end

    include_examples "blank validation", :email, "Enter an email address"
    include_examples "blank validation", :telephone, "Enter a telephone number"
    include_examples "blank validation", :website, "Enter a website address"
    include_examples "blank validation", :address1, "Enter address line 1"
    include_examples "blank validation", :town, "Enter a town or city"
    include_examples "blank validation", :postcode, "Enter a postcode"

    {
      "a" => "Enter a telephone number, like 01632 960 001, 07700 900 982 or +44 0808 157 0192",
      nil => "Enter a telephone number",
      "123456791123456789" => "Telephone number must contain 15 numbers or fewer",
      "1234567" => "Telephone number must contain 8 numbers or more",
    }.each do |telephone, message|
      it "shows '#{message}' when the telephone is #{telephone.inspect}" do
        wizard_step.telephone = telephone

        expect(wizard_step).not_to be_valid
        expect(wizard_step.errors[:telephone]).to contain_exactly(message)
      end
    end

    it "rejects a website without a scheme" do
      wizard_step.website = "www.example.com"

      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors[:website]).to contain_exactly("Enter a website address in the correct format, like https://www.example.com")
    end
  end
end
