# frozen_string_literal: true

require "rails_helper"

describe CoursePublishableSchoolsRolloverValidator do
  let(:course) { build_stubbed(:course) }
  let(:enrichment) { instance_double(CourseEnrichment, rolled_over?: true) }

  def run_validator
    course.errors.clear
    described_class.new.validate(course)
  end

  before do
    allow(course).to receive_messages(
      schools_validated?: false,
      latest_enrichment: enrichment,
    )
  end

  it "is a no-op when schools_validated? is true" do
    allow(course).to receive(:schools_validated?).and_return(true)

    run_validator

    expect(course.errors[:sites]).to be_empty
  end

  it "is a no-op when there is no latest enrichment" do
    allow(course).to receive(:latest_enrichment).and_return(nil)

    run_validator

    expect(course.errors[:sites]).to be_empty
  end

  it "is a no-op when the latest enrichment is not rolled over" do
    allow(enrichment).to receive(:rolled_over?).and_return(false)

    run_validator

    expect(course.errors[:sites]).to be_empty
  end

  it "adds a :check_schools error when a school is attached" do
    allow(Courses::PublishRules::SchoolPresence).to receive(:any?).with(course).and_return(true)

    run_validator

    expect(course.errors.details[:sites]).to include(error: :check_schools)
  end

  it "adds an :enter_schools error when no school is attached and the exemption does not apply" do
    allow(Courses::PublishRules::SchoolPresence).to receive(:any?).with(course).and_return(false)
    allow(Courses::PublishRules::SchoolPresenceExemption).to receive(:applies?).with(course).and_return(false)

    run_validator

    expect(course.errors.details[:sites]).to include(error: :enter_schools)
  end

  it "does not add an :enter_schools error when no school is attached but the exemption applies" do
    allow(Courses::PublishRules::SchoolPresence).to receive(:any?).with(course).and_return(false)
    allow(Courses::PublishRules::SchoolPresenceExemption).to receive(:applies?).with(course).and_return(true)

    run_validator

    expect(course.errors[:sites]).to be_empty
  end

  it "still adds a :check_schools error when schools are attached, regardless of the exemption" do
    allow(Courses::PublishRules::SchoolPresence).to receive(:any?).with(course).and_return(true)
    allow(Courses::PublishRules::SchoolPresenceExemption).to receive(:applies?).with(course).and_return(true)

    run_validator

    expect(course.errors.details[:sites]).to include(error: :check_schools)
  end
end
