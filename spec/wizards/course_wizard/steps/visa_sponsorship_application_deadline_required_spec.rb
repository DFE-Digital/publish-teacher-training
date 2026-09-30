# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Steps::VisaSponsorshipApplicationDeadlineRequired do
  include_context "add_course_wizard"

  let(:current_step) { :visa_sponsorship_application_deadline_required }
  let(:visa_sponsorship_application_deadline_required) { nil }
  let(:wizard_step) { wizard.current_step }

  describe "#valid?" do
    it "is valid when visa_sponsorship_application_deadline_required is true" do
      wizard_step.visa_sponsorship_application_deadline_required = true

      expect(wizard_step).to be_valid
    end

    it "is valid when visa_sponsorship_application_deadline_required is false" do
      wizard_step.visa_sponsorship_application_deadline_required = false

      expect(wizard_step).to be_valid
    end

    it "is invalid when visa_sponsorship_application_deadline_required is nil" do
      wizard_step.visa_sponsorship_application_deadline_required = nil

      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors.messages_for(:visa_sponsorship_application_deadline_required)).to contain_exactly("Select if there is a deadline for applications that require visa sponsorship")
    end
  end
end
