# frozen_string_literal: true

require 'rails_helper'

module Publish
  describe SubjectRequirementForm, type: :model do
    let(:params) { { additional_degree_subject_requirements: true, degree_subject_requirements: "#{(%w[word] * 250).join(' ')} popped" } }

    subject { described_class.new(params) }

    describe 'validations' do
      before { subject.valid? }

      it 'validates :degree_subject_requirements does not exceed 250 words' do
        expect(subject.errors[:degree_subject_requirements]).to include('Reduce the word count for degree subject requirements')
      end
    end
  end
end
