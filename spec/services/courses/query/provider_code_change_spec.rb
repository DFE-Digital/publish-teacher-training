# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::Query do # rubocop:disable RSpec/SpecFilePathFormat
  it "still finds a training provider's courses in Find after its provider code changes" do
    provider = create(:provider, provider_code: "Q10", provider_name: "Findable Training Provider")
    course = create(:course, :with_full_time_sites, :published, provider:, course_code: "X123")

    expect(described_class.call(params: { provider_code: "Q10" })).to include(course)

    # The support form refuses this change once a course has been published.
    # Find looks courses up through provider_id, so a changed code still matches.
    provider.update!(provider_code: "Z99")

    expect(described_class.call(params: { provider_code: "Z99" })).to include(course)
    expect(described_class.call(params: { provider_code: "Q10" })).not_to include(course)
    expect(described_class.call(params: { provider_name: "Findable Training Provider" })).to include(course)

    found_provider = RecruitmentCycle.current.providers.find_by!(provider_code: "Z99")
    expect(found_provider.courses.find_by!(course_code: "X123")).to eq(course)
  end
end
