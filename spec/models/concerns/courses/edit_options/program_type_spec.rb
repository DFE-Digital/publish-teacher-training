require 'rails_helper'

describe Courses::EditOptions::ProgramTypeConcern do
  let(:example_model) do
    klass = Class.new do
      include Courses::EditOptions::ProgramTypeConcern

      def self_accredited?; end
      def provider_is_a_scitt?; end
    end

    klass.new
  end

  context 'for a SCITTs self accredited courses' do
    let(:self_accredited_value) { true }
    let(:provider_is_a_scitt_value) { 'Y' }

    before do
      allow(example_model).to receive(:self_accredited?).and_return(self_accredited_value)
      allow(example_model).to receive(:provider_is_a_scitt?).and_return(provider_is_a_scitt_value)
    end

    it 'returns the correct pgoramme type' do
      expect(example_model.program_type_options).to eq(%i[pg_teaching_apprenticeship scitt_programme])
    end
  end

  context 'for a HEIs self accredited courses' do
    let(:self_accredited_value) { true }
    let(:provider_is_a_scitt_value) { false }

    before do
      allow(example_model).to receive(:self_accredited?).and_return(self_accredited_value)
      allow(example_model).to receive(:provider_is_a_scitt?).and_return(provider_is_a_scitt_value)
    end

    it 'returns the correct pgoramme type' do
      expect(example_model.program_type_options).to eq(%i[pg_teaching_apprenticeship higher_education_programme])
    end
  end

  context 'for non-self accredited courses' do
    let(:self_accredited_value) { false }

    before do
      allow(example_model).to receive(:self_accredited?).and_return(self_accredited_value)
    end

    it 'returns the correct programme types for users to co choose between' do
      expect(example_model.program_type_options).to eq(%i[pg_teaching_apprenticeship school_direct_training_programme school_direct_salaried_training_programme])
    end
  end
end
