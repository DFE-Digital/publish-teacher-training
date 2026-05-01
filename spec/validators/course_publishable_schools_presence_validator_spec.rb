# frozen_string_literal: true

require "rails_helper"

describe CoursePublishableSchoolsPresenceValidator do
  let(:course) { build_stubbed(:course) }

  def run_validator
    course.errors.clear
    described_class.new.validate(course)
  end

  it "does not add an error when SchoolPresence reports schools attached" do
    allow(Courses::PublishRules::SchoolPresence).to receive(:any?).with(course).and_return(true)

    run_validator

    expect(course.errors[:sites]).to be_empty
  end

  it "adds a :blank error on :sites when SchoolPresence reports no schools" do
    allow(Courses::PublishRules::SchoolPresence).to receive(:any?).with(course).and_return(false)

    run_validator

    expect(course.errors.details[:sites]).to include(error: :blank)
  end
end
