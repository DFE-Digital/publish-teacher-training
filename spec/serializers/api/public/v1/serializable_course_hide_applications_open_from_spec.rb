# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::Public::V1::SerializableCourse do
  subject(:json) { JSON.parse(resource.as_jsonapi.to_json) }

  let(:enrichment) { build(:course_enrichment, :published) }
  let(:course) { create(:course, :with_accrediting_provider, enrichments: [enrichment], funding: "apprenticeship") }
  let(:resource) { described_class.new(object: course) }

  it "returns applications_open_from from the recruitment cycle when the flag is on" do
    FeatureFlag.activate(:hide_applications_open_date)

    expect(json["attributes"]).to have_key("applications_open_from")

    expect(json["attributes"]["applications_open_from"]).to eq(
      course.recruitment_cycle.application_start_date.iso8601,
    )
  end

  it "returns the course applications_open_from when the flag is off" do
    FeatureFlag.deactivate(:hide_applications_open_date)

    expect(json["attributes"]).to have_key("applications_open_from")

    expect(json["attributes"]["applications_open_from"]).to eq(
      course.applications_open_from.iso8601,
    )
  end
end
