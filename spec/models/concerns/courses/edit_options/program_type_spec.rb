require 'rails_helper'

describe Courses::EditOptions::ProgramTypeConcern do
  let(:example_model) do
    klass = Class.new do
      include Courses::EditOptions::ProgramTypeConcern
      attr_accessor :self_accredited_value
      attr_accessor :scitt_value

      def self_accredited?
        self_accredited_value
      end

      def provider_is_a_scitt?
        scitt_value
      end
    end

    klass.new
  end

  context 'for a SCITTs self accredited courses' do
    before do
      example_model.self_accredited_value = true
      example_model.scitt_value = 'Y'
    end

    it 'returns the correct pgoramme type' do
      expect(example_model.program_type_options).to eq(%i[pg_teaching_apprenticeship scitt_programme])
    end
  end

  context 'for a HEIs self accredited courses' do
    before do
      example_model.self_accredited_value = true
      example_model.scitt_value = nil
    end

    it 'returns the correct pgoramme type' do
      expect(example_model.program_type_options).to eq(%i[pg_teaching_apprenticeship higher_education_programme])
    end
  end

  context 'for non-self accredited courses' do
    before do
      example_model.self_accredited_value = false
    end

    it 'returns the correct programme types for users to co choose between' do
      expect(example_model.program_type_options).to eq(%i[pg_teaching_apprenticeship school_direct_training_programme school_direct_salaried_training_programme])
    end
  end
end
