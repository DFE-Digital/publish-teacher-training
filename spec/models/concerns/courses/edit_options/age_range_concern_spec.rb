require 'rails_helper'

describe Courses::EditOptions::AgeRangeConcern do
  let(:example_model) do
    klass = Class.new do
      include Courses::EditOptions::AgeRangeConcern
      attr_accessor :ucas_level
    end

    klass.new
  end

  before do
    example_model.ucas_level = level_value
  end

  context 'for primary' do
    let(:level_value) { :primary }
    it 'returns the correct ages range for users to choose between' do
      expect(example_model.age_range_options).to eq(%w[3_to_7 5_to_11 7_to_11 7_to_14])
    end
  end

  context 'for secondary' do
    let(:level_value) { :secondary }
    it 'returns the correct age ranges for users to choose between' do
      expect(example_model.age_range_options).to eq(%w[11_to_16 11_to_18 14_to_19])
    end
  end
end
