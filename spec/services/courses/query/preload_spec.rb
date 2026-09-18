# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::Query do # rubocop:disable RSpec/SpecFilePathFormat
  subject(:results) { described_class.call(params: {}).to_a }

  before do
    create_list(:course, 3, :published).each { |course| create(:site_status, :findable, course:) }
  end

  # Each result card asks the course whether to show the school experience
  # question, which goes through the provider to its recruitment cycle. The
  # search page renders these in a loop, so the cycle has to come with the
  # provider.
  it "preloads the provider's recruitment cycle for each course" do
    expect(results.size).to eq(3)
    expect(results.map { |course| course.provider.association(:recruitment_cycle).loaded? }).to all(be(true))
    expect(count_queries { results.each(&:show_school_experience?) }).to eq(0)
  end
end
