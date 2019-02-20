require 'rails_helper'

describe "Course Factory" do
  let(:course) { create(:course, is_pgde: true) }

  it "created a pgde course" do
    expect(course).to be_instance_of(Course)
    expect(course).to be_valid
    expect(course.in?(Course.pgde)).to be true
  end
end
