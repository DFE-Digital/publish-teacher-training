require 'rails_helper'

describe "Course Factory" do
  let(:course) { create(:course) }

  it "created course" do
    expect(course).to be_instance_of(Course)
    expect(course).to be_valid
  end

  context "course resulting_in_pgde" do
    let(:course) { create(:course, :resulting_in_pgde) }

    it "created course" do
      expect(course.pgde?).to be true
    end
  end

  context "course in_further_education" do
    let(:course) { create(:course, :in_further_education) }

    it "created course" do
      expect(course.subjects.further_education.any?).to be true
    end
  end
end
