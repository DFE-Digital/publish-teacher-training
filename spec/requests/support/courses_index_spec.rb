# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support::CoursesController#index", travel: mid_cycle do
  include DfESignInUserHelper

  before { host! URI(Settings.base_url).host }

  def render_courses_for(course_count)
    provider = create(:provider)
    accredited_provider = create(:accredited_provider, recruitment_cycle: provider.recruitment_cycle)
    create_list(:course, course_count, :with_full_time_sites, provider:, accredited_provider_code: accredited_provider.provider_code)
    # A course that has never been published takes a different path through
    # Courses::ContentStatusService, which reads the course's enrichments.
    create_list(:course, course_count, provider:, accredited_provider_code: accredited_provider.provider_code).each do |course|
      create(:course_enrichment, :initial_draft, course:)
    end

    login_user(create(:user, :admin))
    count_queries do
      get "/support/#{provider.recruitment_cycle_year}/providers/#{provider.id}/courses"
    end
  end

  # Every row reads the course's status (site statuses, the enrichments, the
  # provider's recruitment cycle) and its ratifying provider. Bullet does not
  # raise in test, so this is what catches a preload that stops matching what
  # the row reads.
  it "renders the list in a constant number of queries regardless of course count" do
    many = render_courses_for(5)
    few = render_courses_for(2)

    expect(response.parsed_body.css(".course-row").size).to eq(4)
    expect(many).to eq(few)
  end
end
