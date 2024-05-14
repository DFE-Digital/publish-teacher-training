# frozen_string_literal: true

require 'rails_helper'

describe Courses::EditOptions::QualificationConcern do
  let(:example_model) do
    klass = Class.new do
      include Courses::EditOptions::QualificationConcern
      attr_accessor :level

      def tda_active?; end
    end

    klass.new
  end

  before do
    example_model.level = level_value
  end

  context 'for a course that’s not further education' do
    let(:level_value) { 'primary' }

    it 'returns only QTS options for users to choose between' do
      expect(example_model.qualification_options).to eq(%w[qts pgce_with_qts pgde_with_qts])
      expect(example_model.qualification_options).to all(include('qts'))
    end
  end

  context 'for a further education course' do
    let(:level_value) { 'further_education' }

    it 'returns only QTS options for users to choose between' do
      expect(example_model.qualification_options).to eq(%w[pgce pgde])
      example_model.qualification_options.each do |q|
        expect(q).not_to include('qts')
      end
    end
  end

  context 'for a teacher degree apprenticeship course' do
    let(:level_value) { 'secondary' }

    before do
      allow(example_model).to receive(:tda_active?).and_return true
    end

    it 'returns a teacher degree apprenticeship' do
      expect(example_model.qualification_options).to eq(%w[qts pgce_with_qts pgde_with_qts undergraduate_degree_with_qts])
    end
  end
end
