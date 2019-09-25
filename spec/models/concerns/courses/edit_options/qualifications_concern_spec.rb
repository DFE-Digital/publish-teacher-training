require "rails_helper"

describe Courses::EditOptions::QualificationConcern do
  let(:example_model) do
    klass = Class.new do
      include Courses::EditOptions::QualificationConcern
      attr_accessor :ucas_level
    end

    klass.new
  end

  before do
    example_model.ucas_level = level_value
  end

  context "for a course that’s not further education" do
    let(:level_value) { :primary }

    it "returns only QTS options for users to choose between" do
      expect(example_model.qualification_options).to eq(%w[qts pgce_with_qts pgde_with_qts])
      example_model.qualification_options.each do |q|
        expect(q).to include("qts")
      end
    end
  end

  context "for a further education course" do
    let(:level_value) { :further_education }

    it "returns only QTS options for users to choose between" do
      expect(example_model.qualification_options).to eq(%w[pgce pgde])
      example_model.qualification_options.each do |q|
        expect(q).not_to include("qts")
      end
    end
  end
end
