# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Find links to robots-blocked URLs", service: :find, travel: mid_cycle(2027) do
  let(:course) do
    create(
      :course,
      :with_full_time_sites,
      :secondary,
      :published,
      :open,
      provider: build(:provider, provider_name: "York university", provider_code: "RO1"),
    )
  end

  before { FeatureFlag.activate(:candidate_accounts) }

  def blocked_links
    response.parsed_body.css('a[href^="/track_click"], a[href*="saved-courses/sign_in"]')
  end

  def nofollow?(link)
    link["rel"].to_s.split.include?("nofollow")
  end

  shared_examples "nofollow on every blocked link" do
    it "marks every link to a robots-blocked URL nofollow" do
      expect(blocked_links).not_to be_empty
      expect(blocked_links.reject { nofollow?(it) }.map { it["href"] }).to be_empty
    end
  end

  context "on the homepage" do
    before { get find_root_path }

    it_behaves_like "nofollow on every blocked link"
  end

  context "on a course page" do
    before { get find_course_path(course.provider_code, course.course_code) }

    it_behaves_like "nofollow on every blocked link"
  end

  context "on the results page" do
    before do
      course
      get find_results_path
    end

    it_behaves_like "nofollow on every blocked link"
  end
end
