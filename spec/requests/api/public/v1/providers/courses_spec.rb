# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::Public::V1::Providers::CoursesController#index", service: :api do
  let(:provider) { create(:provider) }
  let(:accredited_provider) { create(:accredited_provider, recruitment_cycle: provider.recruitment_cycle) }

  def render_courses_for(course_count)
    create_list(:course, course_count, :published, :with_full_time_sites, provider:, accredited_provider_code: accredited_provider.provider_code)

    count_queries do
      get "/api/public/v1/recruitment_cycles/#{provider.recruitment_cycle_year}/providers/#{provider.provider_code}/courses",
          params: { include: "accredited_body" }
    end
  end

  # The serialiser reads every course's status, enrichment fields and
  # ratifying provider, so the search service has to preload them.
  it "serialises the courses in a constant number of queries regardless of course count" do
    few = render_courses_for(2)
    many = render_courses_for(3)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["data"].size).to eq(5)
    expect(many).to eq(few)
  end
end
