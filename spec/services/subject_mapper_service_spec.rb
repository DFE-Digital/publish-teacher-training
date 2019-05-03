require "spec_helper"
require "csv"

describe SubjectMapperService do
  RSpec::Matchers.define :map_to_dfe_subjects do |expected|
    match do |input|
      @input = input
      @actual_dfe_subjects = mapped_subjects(input.fetch(:title, "Any title"), input[:ucas])
      @actual_level = described_class.get_subject_level(input[:ucas])
      contain_exactly(*expected).matches?(@actual_dfe_subjects) &&
        (@actual_level == @expected_level)
    end

    def mapped_subjects(course_title, ucas_subjects)
      described_class.get_subject_list(course_title, ucas_subjects)
    end

    chain :at_level do |level|
      @expected_level = level
    end

    failure_message do |_|
      "expected that UCAS subjects '#{@input[:ucas].join(', ')}' would map to DfE subjects '#{expected.join(', ')}' " +
        "at #{@expected_level} level but was DfE subjects '#{@actual_dfe_subjects.join(', ')}' " +
        "at #{@actual_level} level"
    end
  end

  # Port of https://github.com/DFE-Digital/manage-courses-api/blob/master/tests/ManageCourses.Tests/UnitTesting/SubjectMapperTests.cs
  describe "#get_subject_list" do
    describe "an example of a primary specialisation" do
      subject { { ucas: %w[primary english] } }
      it { should map_to_dfe_subjects(["Primary", "Primary with English"]).at_level(:primary) }
    end

    describe "another example of a primary specialisation" do
      subject { { ucas: %w[primary physics] } }
      it { should map_to_dfe_subjects(["Primary", "Primary with science"]).at_level(:primary) }
    end

    describe "an example of early years (which is absorbed into primary)" do
      subject { { ucas: ["primary", "early years"] } }
      it { should map_to_dfe_subjects(%w[Primary]).at_level(:primary) }
    end

    describe "an example where science should be excluded because it's used as a category" do
      subject { { ucas: ["physics (abridged)", "secondary", "science"] } }
      it { should map_to_dfe_subjects(%w[Physics]).at_level(:secondary) }
    end

    describe "Physics" do
      subject { { ucas: %w[physics secondary science english], title: "Physics" } }
      it { should map_to_dfe_subjects(%w[Physics]).at_level(:secondary) }
    end

    describe "Physics with English" do
      subject { { ucas: %w[physics secondary science english], title: "Physics with English" } }
      it { should map_to_dfe_subjects(%w[Physics English]).at_level(:secondary) }
    end

    describe "Physics with Science" do
      subject { { ucas: %w[physics secondary science english], title: "Physics with Science" } }
      it { should map_to_dfe_subjects(["Physics", "Balanced science"]).at_level(:secondary) }
    end

    describe "Physics with Science and English" do
      subject { { ucas: %w[physics secondary science english], title: "Physics with Science and English" } }
      it { should map_to_dfe_subjects(["Physics", "Balanced science", "English"]).at_level(:secondary) }
    end

    describe "PE (physical education)" do
      subject { { ucas: ["secondary", "physical education"] } }
      it { should map_to_dfe_subjects(["Physical education"]).at_level(:secondary) }
    end

    describe "further education example" do
      subject { { ucas: ["further education", "numeracy"] } }
      it { should map_to_dfe_subjects(["Further education"]).at_level(:further_education) }
    end

    describe "Science used as a category" do
      subject { { ucas: ["computer studies", "science"], title: "Computer science" } }
      it { should map_to_dfe_subjects(%w[Computing]).at_level(:secondary) }
    end

    describe "Computer science with Science" do
      subject { { ucas: ["computer studies", "science"], title: "Computer science with Science" } }
      it { should map_to_dfe_subjects(["Computing", "Balanced science"]).at_level(:secondary) }
    end

    describe "exclude maths from the list of sciences" do
      subject { { ucas: %w[primary mathematics] } }
      it { should map_to_dfe_subjects(["Primary", "Primary with mathematics"]).at_level(:primary) }
    end

    describe "modern foreign languages (Chinese)" do
      subject { { ucas: ["secondary", "languages", "languages (asian)", "chinese"] } }
      it { should map_to_dfe_subjects(%w[Mandarin]).at_level(:secondary) }
    end

    describe "modern foreign languages (other)" do
      subject { { ucas: %w[languages] } }
      it { should map_to_dfe_subjects(["Modern languages (other)"]).at_level(:secondary) }
    end

    describe "latin and classics have been merged" do
      subject { { ucas: %w[latin] } }
      it { should map_to_dfe_subjects(%w[Classics]).at_level(:secondary) }
    end

    describe "Primary with hist/geo have beeen merged" do
      subject { { ucas: %w[primary history] } }
      it { should map_to_dfe_subjects(["Primary", "Primary with geography and history"]).at_level(:primary) }
    end

    describe "primary PE" do
      subject { { ucas: ["primary", "physical education"] } }
      it { should map_to_dfe_subjects(["Primary", "Primary with physical education"]).at_level(:primary) }
    end

    describe "secondary computing" do
      subject { { ucas: ["secondary", "computer studies", "information communication technology"] } }
      it { should map_to_dfe_subjects(%w[Computing]).at_level(:secondary) }
    end

    describe "secondary ESOL" do
      subject { { ucas: ["mandarin", "english as a second or other language"] } }
      it { should map_to_dfe_subjects(["Mandarin", "English as a second or other language"]).at_level(:secondary) }
    end

    describe "PCET ESOL" do
      subject { { ucas: ["further education", "english as a second or other language"] } }
      it { should map_to_dfe_subjects(["Further education"]).at_level(:further_education) }
    end

    describe "secondary English" do
      subject { { ucas: %w[secondary english], title: "English" } }
      it { should map_to_dfe_subjects(%w[English]).at_level(:secondary) }
    end

    describe "using subject-mapper-test-data.csv" do
      CSV.foreach("#{Dir.pwd}/spec/services/subject-mapper-test-data.csv",
                  encoding: "UTF-8",
                  headers: true,
                  header_converters: :symbol).with_index do |row, i|

        describe "Test case row '#{i}': subjects #{row[:ucas_subjects]}, title: #{row[:course_title]}" do
          subject { described_class.get_subject_list(row[:course_title], row[:ucas_subjects].split(",")) }
          it { should match_array row[:expected_subjects]&.split(",") || [] }
        end
      end
    end
  end
end
