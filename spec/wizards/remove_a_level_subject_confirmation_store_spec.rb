# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RemoveALevelSubjectConfirmationStore do
  subject(:store) { described_class.new(wizard) }

  let(:wizard) do
    ALevelsWizard.new(
      current_step: :remove_a_level_subject_confirmation,
      provider:,
      course:,
      step_params: ActionController::Parameters.new(
        { remove_a_level_subject_confirmation: ActionController::Parameters.new(step_params) }
      )
    )
  end
  let(:provider) { create(:provider) }
  let(:course) { create(:course, :with_a_level_requirements, a_level_subject_requirements:) }
  let(:a_level_subject_requirements) do
    [
      { 'uuid' => 'the-uuid-1', 'subject' => 'any_subject', 'minimum_grade_required' => 'B' },
      { 'uuid' => 'the-uuid-2', 'subject' => 'other_subject', 'other_subject' => 'Mathematics', 'minimum_grade_required' => 'A' }
    ]
  end
  let(:step_params) do
    { uuid: 'the-uuid-1', confirmation: }
  end
  let(:confirmation) { nil }

  describe '#destroy' do
    context 'when confirmation is yes' do
      let(:confirmation) { 'yes' }

      it 'removes the hash with the given uuid from a_level_subject_requirements and updates the course' do
        expect(course.a_level_subject_requirements.size).to eq(2)

        store.destroy

        expect(course.reload.a_level_subject_requirements.size).to eq(1)
        expect(course.a_level_subject_requirements.any? { |req| req['uuid'] == 'the-uuid-1' }).to be_falsey
      end
    end

    context 'when removing the last A level subject requirement' do
      let(:confirmation) { 'yes' }
      let(:a_level_subject_requirements) do
        [
          { 'uuid' => 'the-uuid-1', 'subject' => 'any_subject', 'minimum_grade_required' => 'B' }
        ]
      end

      it 'sets specific fields to nil if a_level_subject_requirements becomes empty' do
        store.destroy

        expect(course.reload.a_level_subject_requirements).to be_empty
        expect(course.reload.a_level_requirements).to be_nil
        expect(course.accept_pending_a_level).to be_nil
        expect(course.accept_a_level_equivalency).to be_nil
        expect(course.additional_a_level_equivalencies).to be_nil
      end
    end

    context 'when confirmation is not yes' do
      let(:confirmation) { 'no' }

      it 'does not remove any hash and does not alter the a_level_subject_requirements' do
        expect(course).not_to receive(:find_a_level_subject_requirement!)

        store.destroy

        expect(course.reload.a_level_subject_requirements.size).to eq(2)
      end
    end
  end
end
