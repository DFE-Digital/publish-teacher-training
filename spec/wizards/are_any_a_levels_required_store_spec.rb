# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AreAnyALevelsRequiredStore do
  subject(:store) { described_class.new(wizard) }

  let(:course) { create(:course) }
  let(:provider) { build(:provider) }
  let(:current_step) { :are_any_a_levels_required_for_this_course }

  let(:wizard) do
    ALevelsWizard.new(
      current_step:,
      provider:,
      course:,
      step_params: ActionController::Parameters.new(
        { current_step => ActionController::Parameters.new(step_params) }
      )
    )
  end

  describe '#save' do
    subject { store.save }

    context 'when current step answer is yes' do
      let(:step_params) { { answer: 'yes' } }

      it 'updates course a_level_requirements to true' do
        expect { subject }.to change { course.reload.a_level_requirements }.to(true)
      end
    end

    context 'when current step answer is yes and existing a level subject requirements' do
      let(:course) { create(:course, :with_teacher_degree_apprenticeship, :with_a_level_requirements) }
      let(:step_params) { { answer: 'yes' } }

      it 'preserve existing a level subject requirements' do
        expect(course.a_level_subject_requirements).to be_present
        store.save
        expect(course.a_level_subject_requirements).to be_present
      end
    end

    context 'when current step answer is no' do
      let(:step_params) { { answer: 'no' } }

      it 'updates course a_level_requirements to false' do
        expect { subject }.to change { course.reload.a_level_requirements }.to(false)
      end
    end

    context 'when current step answer is no and existing a level subject requirements' do
      let(:course) { create(:course, :with_teacher_degree_apprenticeship, :with_a_level_requirements) }
      let(:step_params) { { answer: 'no' } }

      it 'remove existing a level fields' do
        expect(course.a_level_subject_requirements).to be_present

        store.save
        course.reload

        expect(course.a_level_subject_requirements).to eq([])
        expect(course.accept_pending_a_level).to be_nil
        expect(course.accept_a_level_equivalency).to be_nil
        expect(course.additional_a_level_equivalencies).to be_nil
      end
    end
  end
end
