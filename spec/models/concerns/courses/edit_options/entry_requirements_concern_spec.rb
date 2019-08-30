require 'rails_helper'

describe Courses::EditOptions::EntryRequirementsConcern do
  let(:example_model) do
    klass = Class.new do
      include Courses::EditOptions::EntryRequirementsConcern
    end

    klass.new
  end

  context 'entry_requirements' do
    it 'returns the entry requirements that users can choose between' do
      expect(example_model.entry_requirements).to eq(%i[must_have_qualification_at_application_time expect_to_achieve_before_training_begins equivalence_test])
    end
  end
end
