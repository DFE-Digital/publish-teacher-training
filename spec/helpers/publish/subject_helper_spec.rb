# frozen_string_literal: true

require 'rails_helper'

describe Publish::SubjectHelper do
  describe '#primary_form_options' do
    subject { primary_form_options(subjects) }

    let(:subjects) { [find_or_create(:primary_subject, :primary_with_science)] }

    it 'returns primary subject id' do
      expect(subject.first.id).to eq subjects.first.id
    end

    it 'returns primary subject name' do
      expect(subject.first.name).to eq subjects.first.subject_name
    end
  end
end
