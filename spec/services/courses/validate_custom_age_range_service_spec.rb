require "rails_helper"

describe Courses::ValidateCustomAgeRangeService do
  let(:service) { described_class.new }
  let(:course) { build(:course, age_range_in_years: age_range_in_years) }
  let(:execute_service) { service.execute(age_range_in_years, course) }

  before do
    execute_service
  end


  context "with a valid age range" do
    let(:age_range_in_years) { "4_to_8" }
    it "age_range_in_years attribute to the correct value" do
      expect(course.errors.count).to eq(0)
    end
  end

  context "an invalid age range" do
    let(:error_message) { "is invalid. You must enter a valid age range." }

    context "with an age range of with a gap of less than 4 years" do
      let(:age_range_in_years) { "5_to_8" }
      let(:error_message) { "is invalid. Your age range must cover at least 4 years." }

      it "should return an error stating valid age ranges must be 4 years or greater" do
        expect(course.errors.messages[:age_range_in_years]).to include "#{age_range_in_years} #{error_message}"
      end
    end

    context "with a from value that does not fall within the valid age range" do
      let(:age_range_in_years) { "1_to_15" }

      it "should return an error" do
        expect(course.errors.messages[:age_range_in_years]).to include "#{age_range_in_years} #{error_message}"
      end
    end

    context "with a to value that does not fall within the valid age range" do
      let(:age_range_in_years) { "7_to_19" }

      it "should return an error stating valid age ranges must be 4 years or greater" do
        expect(course.errors.messages[:age_range_in_years]).to include "#{age_range_in_years} #{error_message}"
      end
    end

    context "with an age range that does not include a valid from age range value" do
      let(:age_range_in_years) { "to_6" }

      it "should return an error stating that there is an invalid from year" do
        expect(course.errors.messages[:age_range_in_years]).to include "#{age_range_in_years} #{error_message}"
      end
    end

    context "with an age range that does not include a valid to age range value" do
      let(:age_range_in_years) { "2_to" }

      it "should return an error stating that there is an invalid from year" do
        expect(course.errors.messages[:age_range_in_years]).to include "#{age_range_in_years} #{error_message}"
      end
    end
  end
end
