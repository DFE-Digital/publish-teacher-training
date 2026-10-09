# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::Public::V1::Providers::Courses::LocationsController#index", service: :api do
  # Course locations are Course::School rows. The endpoint preloads the
  # school, its GIAS record and its provider school.
  let(:recruitment_cycle) { find_or_create(:recruitment_cycle, year: Settings.schools_remodel_cycle_year) }
  let(:provider) { create(:provider, recruitment_cycle:) }

  def render_locations_for(school_count)
    course = create(:course, provider:)
    create_list(:course_school, school_count, course:)

    count_queries do
      get "/api/public/v1/recruitment_cycles/#{recruitment_cycle.year}/providers/#{provider.provider_code}/courses/#{course.course_code}/locations",
          params: { include: "provider" }
    end
  end

  # Every serialised location links to its provider and recruitment cycle, and
  # Bullet cannot catch this one: it keys objects by class and id, so preloading
  # the same Site through site_statuses marks the association loaded for the
  # instances course.sites returns, which still query.
  it "serialises the locations in a constant number of queries regardless of how many there are" do
    few = render_locations_for(2)
    many = render_locations_for(3)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["data"].size).to eq(3)
    expect(many).to eq(few)
  end
end
