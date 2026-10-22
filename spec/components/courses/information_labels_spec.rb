# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::InformationLabels do
  subject(:labels) { described_class.new(course) }

  let(:course) do
    build(
      :course,
      funding: "fee",
      qualification: :pgce_with_qts,
      study_mode: :full_time_or_part_time,
      start_date: Time.zone.local(2027, 9, 1),
    )
  end

  it "formats the lines the course lists share" do
    expect(labels.funding).to eq("Fee-paying")
    expect(labels.qualification).to eq("QTS with PGCE")
    expect(labels.study_mode).to eq("Full time or part time")
    expect(labels.start_date).to eq("September 2027")
  end

  it "returns no start date when the course has none" do
    course.start_date = nil

    expect(labels.start_date).to be_nil
  end
end
