require 'rails_helper'

describe "Course Factory" do
  let(:course) { create(:course) }

  it "created course" do
    expect(course).to be_instance_of(Course)
    expect(course).to be_valid
  end

  context "course with_pgde_course" do
    let(:course) { create(:course_with_qualication, :with_pgde_course) }

    it "created course" do
      expect(course.in?(Course.pgde)).to be true
    end
  end

  context "course with_further_education_subject" do
    let(:course) { create(:course_with_qualication, :with_further_education_subject) }

    it "created course" do
      expect(course.subjects.further_education.any?).to be true
    end
  end
end
