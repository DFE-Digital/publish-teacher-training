# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WhatALevelIsRequiredStore do
  subject(:store) { described_class.new(wizard) }

  let(:course) { create(:course) }
  let(:provider) { build(:provider) }
  let(:current_step) { :what_a_level_is_required }

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

    context 'when creating an A level other subject requirements' do
      let(:step_params) { { subject: 'other_subject', other_subject: 'Mathematics', minimum_grade_required: 'D', uuid: SecureRandom.uuid } }

      before do
        allow(SecureRandom).to receive(:uuid).and_return('a1b2c3d4')
      end

      it 'updates the course a_level_subject_requirements correctly' do
        expect { subject }.to change { wizard.course.reload.a_level_subject_requirements }
          .to([{ 'subject' => 'other_subject', 'other_subject' => 'Mathematics', 'minimum_grade_required' => 'D', 'uuid' => 'a1b2c3d4' }])
      end
    end

    context 'when creating an A level subject requirements' do
      let(:step_params) { { subject: 'any_subject', minimum_grade_required: 'D', uuid: SecureRandom.uuid } }

      before do
        allow(SecureRandom).to receive(:uuid).and_return('e5f6g7h8')
      end

      it 'updates the course a_level_subject_requirements correctly' do
        expect { subject }.to change { wizard.course.reload.a_level_subject_requirements }
          .to([{ 'subject' => 'any_subject', 'minimum_grade_required' => 'D', 'uuid' => 'e5f6g7h8' }])
      end
    end

    context 'when creating an A level subject requirements without minimal grade' do
      let(:step_params) { { subject: 'other_subject', other_subject: 'Mathematics', uuid: SecureRandom.uuid } }

      before do
        allow(SecureRandom).to receive(:uuid).and_return('i9j0k1l2')
      end

      it 'updates the course a_level_subject_requirements correctly' do
        expect { subject }.to change { wizard.course.reload.a_level_subject_requirements }
          .to([{ 'uuid' => 'i9j0k1l2', 'subject' => 'other_subject', 'other_subject' => 'Mathematics' }])
      end
    end

    context 'when adding to an existing A level subject requirements' do
      let(:course) { create(:course, :with_a_level_requirements) }
      let(:step_params) { { subject: 'any_stem_subject', minimum_grade_required: 'D', uuid: 'yh5tre2' } }

      before do
        allow(SecureRandom).to receive(:uuid).and_return('m3n4o5p6')
      end

      it 'adds the course a_level_subject_requirements correctly' do
        expect { subject }.to change { wizard.course.reload.a_level_subject_requirements }
          .to([{ 'uuid' => 'm3n4o5p6', 'subject' => 'any_subject', 'minimum_grade_required' => 'A' }, { 'subject' => 'any_stem_subject', 'minimum_grade_required' => 'D', 'uuid' => 'yh5tre2' }])
      end
    end

    context 'when updating an A level other subject requirements' do
      let(:course) { create(:course, :with_a_level_requirements, a_level_subject_requirements: [{ uuid: 'm3n4o5p6', subject: 'any_stem_subject' }]) }
      let(:step_params) { { subject: 'other_subject', other_subject: 'Mathematics', minimum_grade_required: 'D', uuid: 'm3n4o5p6' } }

      it 'updates the course a_level_subject_requirements correctly' do
        expect { subject }.to change { wizard.course.reload.a_level_subject_requirements }
          .to([{ 'subject' => 'other_subject', 'other_subject' => 'Mathematics', 'minimum_grade_required' => 'D', 'uuid' => 'm3n4o5p6' }])
      end
    end
  end
end
