# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ALevelSubjectRequirementRowComponent do
  subject(:component) { described_class.new(a_level_subject_requirement) }

  describe '#row_value' do
    subject { component.row_value }

    context 'when subject is any_subject with minimum grade B' do
      let(:a_level_subject_requirement) { { subject: 'any_subject', minimum_grade_required: 'B' } }

      it 'returns "Any subject - Grade B or above"' do
        expect(subject).to eq('Any subject - Grade B or above')
      end
    end

    context 'when subject is any_subject without minimum grade' do
      let(:a_level_subject_requirement) { { subject: 'any_subject' } }

      it 'returns "Any subject"' do
        expect(subject).to eq('Any subject')
      end
    end

    context 'when subject is any_subject with minimum grade A*' do
      let(:a_level_subject_requirement) { { subject: 'any_subject', minimum_grade_required: 'A*' } }

      it 'returns "Any subject - Grade A*"' do
        expect(subject).to eq('Any subject - Grade A*')
      end
    end

    context 'when subject is other_subject with other subject Mathematics and minimum grade A' do
      let(:a_level_subject_requirement) { { subject: 'other_subject', other_subject: 'Mathematics', minimum_grade_required: 'A' } }

      it 'returns "Mathematics - Grade A or above"' do
        expect(subject).to eq('Mathematics - Grade A or above')
      end
    end

    context 'when subject is other_subject with other subject Mathematics and minimum grade B' do
      let(:a_level_subject_requirement) { { subject: 'other_subject', other_subject: 'Mathematics', minimum_grade_required: 'B' } }

      it 'returns "Mathematics - Grade B or above"' do
        expect(subject).to eq('Mathematics - Grade B or above')
      end
    end

    context 'when subject is other_subject with other subject Mathematics and custom minimum grade' do
      let(:a_level_subject_requirement) { { subject: 'other_subject', other_subject: 'Mathematics', minimum_grade_required: 'Grade ABC or above' } }

      it 'returns "Mathematics - Grade B or above"' do
        expect(subject).to eq('Mathematics - Grade ABC or above')
      end
    end

    context 'when subject is other_subject with other subject Mathematics and no minimum grade' do
      let(:a_level_subject_requirement) { { subject: 'other_subject', other_subject: 'Mathematics' } }

      it 'returns "Mathematics - Grade B or above"' do
        expect(subject).to eq('Mathematics')
      end
    end
  end
end
