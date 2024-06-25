# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ALevelSteps::WhatALevelIsRequired, type: :model do
  subject(:wizard_step) { described_class.new }

  describe 'validations' do
    it 'is valid with a subject' do
      wizard_step.subject = 'Any subject'
      expect(wizard_step).to be_valid
    end

    it 'is not valid without a subject' do
      wizard_step.subject = nil
      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors.added?(:subject, :blank)).to be true
    end

    context 'when subject is "other_subject"' do
      before do
        wizard_step.subject = 'other_subject'
      end

      it 'is valid with other_subject present' do
        wizard_step.other_subject = 'Physics'
        expect(wizard_step).to be_valid
      end

      it 'is not valid without other_subject' do
        wizard_step.other_subject = nil
        expect(wizard_step).not_to be_valid
        expect(wizard_step.errors.added?(:other_subject, :blank)).to be true
      end
    end
  end

  describe '.permitted_params' do
    it 'returns the correct permitted params' do
      expect(described_class.permitted_params).to eq(%i[subject other_subject minimum_grade_required])
    end
  end

  describe '#subjects_list' do
    it 'returns a list of subjects' do
      expect(wizard_step.subjects_list).to be_an(Array)
      expect(wizard_step.subjects_list.first).to be_an(Struct)
      expect(wizard_step.subjects_list.first.name).to eq('Accounting')
      expect(wizard_step.subjects_list.last.name).to eq('World Development')
    end
  end

  describe '#next_step' do
    it 'returns the add a level to the list page' do
      expect(wizard_step.next_step).to be :add_a_level_to_a_list
    end
  end
end
