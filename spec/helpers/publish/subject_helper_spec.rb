# frozen_string_literal: true

require 'rails_helper'

describe Publish::SubjectHelper do
  describe '#primary_form_options' do
    subject { primary_form_options(subjects) }

    let(:subjects) { [find_or_create(:primary_subject, :primary_with_english)] }

    it 'returns primary subject code' do
      expect(subject.first.code).to eq 1 + subjects.first.subject_code.to_i
    end

    it 'returns primary subject name' do
      expect(subject.first.name).to eq subjects.first.subject_name
    end
  end
end
