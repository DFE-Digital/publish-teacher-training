# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ALevelSteps::AddALevelToAList do
  subject(:wizard_step) { described_class.new(wizard:) }

  let(:provider) { create(:provider) }
  let(:wizard) do
    ALevelsWizard.new(
      current_step: :add_a_level_to_a_list,
      provider:,
      course:,
      step_params: ActionController::Parameters.new({})
    )
  end
  let(:course) { create(:course, :with_teacher_degree_apprenticeship, provider:) }

  describe 'validations' do
    it 'is valid with a valid answer' do
      wizard_step.add_another_a_level = 'yes'
      expect(wizard_step).to be_valid

      wizard_step.add_another_a_level = 'no'
      expect(wizard_step).to be_valid
    end

    it 'is valid without an answer when maximum A level subjects' do
      wizard_step.add_another_a_level = nil
      wizard_step.subjects = [1, 2, 3, 4]
      expect(wizard_step).to be_valid
    end

    it 'is not valid without an answer' do
      wizard_step.add_another_a_level = nil
      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors.added?(:add_another_a_level, :blank)).to be true
    end
  end
end
