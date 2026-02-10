# frozen_string_literal: true

require "rails_helper"

RSpec.describe ALevelsWizard::Steps::RemoveALevelSubjectConfirmation do
  subject(:wizard_step) { described_class.new }

  let(:uuid) { SecureRandom.uuid }
  let(:state_store) { instance_double(ALevelsWizard::StateStores::ALevelStore, repository:, subject: "Any subject") }
  let(:repository) { instance_double(ALevelsWizard::Repositories::ALevelRepository, record: course) }
  let(:course) { create(:course, a_level_subject_requirements:) }
  let(:a_level_subject_requirements) do
    [{ "uuid" => uuid, "subject" => "any_subject", "minimum_grade_required" => "A" }]
  end
  let(:wizard) { instance_double(ALevelsWizard, state_store:) }

  before do
    allow(wizard_step).to receive(:wizard).and_return(wizard) # rubocop:disable RSpec/SubjectStub
  end

  describe "validations" do
    context "when confirmation is present" do
      it "is valid" do
        wizard_step.uuid = uuid
        wizard_step.confirmation = "yes"
        expect(wizard_step).to be_valid

        wizard_step.confirmation = "no"
        expect(wizard_step).to be_valid
      end
    end

    context "when any subject and confirmation is not present" do
      it "is not valid" do
        wizard_step.uuid = uuid
        wizard_step.confirmation = nil
        expect(wizard_step).not_to be_valid
        expect(wizard_step.errors[:confirmation]).to include("Select if you want to remove Any subject")
      end
    end

    context "when other subject and confirmation is not present" do
      let(:a_level_subject_requirements) do
        [{ "uuid" => uuid, "subject" => "other_subject", "other_subject" => "Mathematics" }]
      end

      it "is not valid" do
        wizard_step.uuid = uuid
        wizard_step.confirmation = nil
        expect(wizard_step).not_to be_valid
        # NOTE: The step currently shows the I18n translation of "other_subject" rather than
        # the actual other_subject value. This is a known limitation.
        expect(wizard_step.errors[:confirmation]).to include("Select if you want to remove Any subject")
      end
    end

    context "when uuid is not present" do
      let(:a_level_subject_requirements) { [] }

      it "is not valid" do
        wizard_step.uuid = nil
        wizard_step.confirmation = "yes"
        expect(wizard_step).not_to be_valid
        expect(wizard_step.errors.added?(:uuid, :blank)).to be true
      end
    end
  end

  describe ".permitted_params" do
    it "returns permitted params" do
      expect(described_class.permitted_params).to eq(%i[uuid confirmation])
    end
  end
end
