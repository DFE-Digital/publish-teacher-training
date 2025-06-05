# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::Public::V1::SerializableCourse do
  subject { JSON.parse(resource.as_jsonapi.to_json) }

  let(:enrichment) { build(:course_enrichment, :published) }
  let(:course) { create(:course, :with_accrediting_provider, enrichments: [enrichment], funding: "apprenticeship") }
  let(:resource) { described_class.new(object: course) }

  before do
    FeatureFlag.activate(:hide_applications_open_date)
  end

  it "does not include applications_open_from field" do
    expect(subject).not_to have_key("applications_open_from")
  end
end
