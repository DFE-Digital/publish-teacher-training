# frozen_string_literal: true

require "rails_helper"

describe "Publish::Courses::SchoolPlacementsController#index", service: :publish do
  include DfESignInUserHelper

  before { FeatureFlag.activate(:course_publishing_uses_new_school_model) }
  after { FeatureFlag.deactivate(:course_publishing_uses_new_school_model) }

  def render_placements_for(school_count)
    user = create(:user, :with_provider)
    provider = user.providers.first
    course = create(:course, :published, provider:)
    create_list(:course_school, school_count, course:)

    login_user(user)
    count_queries do
      get "/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/courses/#{course.course_code}/placements"
    end
  end

  # This page's whole purpose is listing a course's schools, and it renders them
  # through Provider::School -> GiasSchool, so the preload has to cover that
  # chain. Bullet does not raise in test, so this is what catches a preload that
  # stops matching the reader.
  it "renders the list in a constant number of queries regardless of school count" do
    many = render_placements_for(5)
    few = render_placements_for(2)

    expect(response.parsed_body.css("#course_school_placements li").size).to eq(2)
    expect(many).to eq(few)
  end
end
