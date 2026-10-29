# frozen_string_literal: true

require "rails_helper"

RSpec.describe Support::AddUserWizard::Steps::Details do
  subject(:wizard_step) { described_class.new(first_name: "Luke", last_name: "Skywalker", email: "luke@jedi.com") }

  describe "#valid?" do
    it "is valid with a name and an unused email" do
      expect(wizard_step).to be_valid
    end

    it "strips and downcases the email before validating" do
      wizard_step.email = "  Luke@Jedi.com  "

      expect(wizard_step).to be_valid
      expect(wizard_step.email).to eq("luke@jedi.com")
    end

    it "is not valid without a first name" do
      wizard_step.first_name = nil

      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors).to be_of_kind(:first_name, :blank)
    end

    it "is not valid without a last name" do
      wizard_step.last_name = nil

      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors).to be_of_kind(:last_name, :blank)
    end

    it "is not valid without an email" do
      wizard_step.email = nil

      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors).to be_of_kind(:email, :blank)
    end

    it "is not valid when the email does not contain @" do
      wizard_step.email = "not-an-email"

      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors[:email]).to include("must contain @")
    end

    it "is not valid when the email is already used" do
      create(:user, email: "luke@jedi.com")

      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors).to be_of_kind(:email, :taken)
    end

    it "allows a non-Department email when the user is not an admin" do
      wizard_step.admin = false

      expect(wizard_step).to be_valid
    end

    it "allows an education.gov.uk email for an admin" do
      wizard_step.email = "luke@education.gov.uk"
      wizard_step.admin = true

      expect(wizard_step).to be_valid
    end

    it "allows a digital.education.gov.uk email for an admin" do
      wizard_step.email = "luke@digital.education.gov.uk"
      wizard_step.admin = true

      expect(wizard_step).to be_valid
    end

    it "is not valid when an admin email is outside the Department domain" do
      wizard_step.admin = true

      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors[:email]).to include("must be an @[digital.]education.gov.uk domain")
    end
  end

  describe "admin" do
    it "defaults to false" do
      expect(described_class.new.admin).to be(false)
    end
  end

  describe ".permitted_params" do
    it "returns the details fields" do
      expect(described_class.permitted_params).to eq(%i[first_name last_name email admin])
    end
  end
end
