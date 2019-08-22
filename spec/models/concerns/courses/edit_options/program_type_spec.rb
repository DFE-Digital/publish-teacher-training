require 'rails_helper'

describe Courses::EditOptions::ProgramTypeConcern do
  let(:example_model) do
    klass = Class.new do
      include Courses::EditOptions::ProgramTypeConcern

      def self_accredited?; end
    end

    klass.new
  end

  before do
    allow(example_model).to receive(:self_accredited?).and_return(self_accredited_value)
  end

  context 'for self accredited courses' do
    let(:self_accredited_value) { true }

    it 'returns the correct pgoramme type' do
      expect(example_model.program_type_options).to eq(%w[Apprenticeship])
    end
  end

  context 'for non-self accredited courses' do
    let(:self_accredited_value) { false }

    it 'returns the correct programme types for users to co choose between' do
      expect(example_model.program_type_options).to eq(%w[Fee paying (no salary), Salaried, Teaching apprenticeship (with salary)])
    end
  end
end
