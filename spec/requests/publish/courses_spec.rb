# frozen_string_literal: true

require "rails_helper"

describe "Publish::CoursesController#index" do
  include DfESignInUserHelper

  let(:user) { create(:user, :with_provider) }
  let(:provider) { user.providers.first }

  def get_courses(query = {})
    login_user(user)
    get "/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/courses", params: query
  end

  def course_names
    response.parsed_body.css(".app-table--courses__course-name").text
  end

  describe "the unfiltered list" do
    before do
      create(:course, :primary, provider:, name: "Primary course")
      create(:course, :secondary, provider:, name: "Secondary course")
    end

    it "is successful" do
      get_courses

      expect(response).to have_http_status(:ok)
    end

    it "lists every course" do
      get_courses

      expect(course_names).to include("Primary course", "Secondary course")
    end

    it "shows the filter panel" do
      get_courses

      expect(response.parsed_body.css(".app-c-filter-section").size).to eq(6)
    end

    it "shows no active filters" do
      get_courses

      expect(response.parsed_body.css(".app-active-filters")).to be_empty
    end
  end

  describe "filtering" do
    before do
      create(:course, :primary, :fee, provider:, name: "Primary course")
      create(:course, :secondary, :salary, provider:, name: "Secondary course")
    end

    it "narrows the list by education phase" do
      get_courses(level: %w[primary])

      expect(course_names).to include("Primary course")
      expect(course_names).not_to include("Secondary course")
    end

    it "narrows the list by fee or salary" do
      get_courses(funding: %w[salary])

      expect(course_names).to include("Secondary course")
      expect(course_names).not_to include("Primary course")
    end

    it "narrows the list on several filters at once" do
      get_courses(level: %w[primary], funding: %w[salary])

      expect(course_names).not_to include("Primary course", "Secondary course")
    end

    it "shows an active filter for each selection" do
      get_courses(level: %w[primary], funding: %w[fee])

      chips = response.parsed_body.css(".app-active-filters__remove-filter").map { |chip| chip.text.gsub("Remove filter", "").strip }

      expect(chips).to eq(%w[Primary Fee-paying])
    end

    it "keeps the selection ticked" do
      get_courses(level: %w[primary])

      expect(response.parsed_body.css("input[name='level[]'][checked]").map { |input| input[:value] }).to eq(%w[primary])
    end

    it "tells the provider when nothing matches" do
      get_courses(level: %w[further_education])

      expect(response.parsed_body.text).to include("No courses found")
    end

    it "ignores a filter value it does not recognise" do
      get_courses(level: %w[bogus])

      expect(course_names).to include("Primary course", "Secondary course")
      expect(response.parsed_body.css(".app-active-filters")).to be_empty
    end

    it "does not reflect a hostile filter value back into the page" do
      payload = "<script>alert(1)</script>"

      get_courses(level: [payload], status: ["' OR 1=1 --"])

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include(payload)
      expect(response.parsed_body.css(".app-active-filters")).to be_empty
      expect(course_names).to include("Primary course", "Secondary course")
    end

    it "ignores params that are not filters" do
      get_courses(order: "something", page: "2")

      expect(response).to have_http_status(:ok)
      expect(course_names).to include("Primary course", "Secondary course")
    end
  end

  describe "the course count" do
    it "counts the courses in each group" do
      create_list(:course, 3, provider:, accrediting_provider: nil)

      get_courses

      expect(response.parsed_body.css(".app-table--courses__count").text.strip).to eq("3 courses")
    end

    it "is singular for one course" do
      create(:course, provider:, accrediting_provider: nil)

      get_courses

      expect(response.parsed_body.css(".app-table--courses__count").text.strip).to eq("1 course")
    end

    it "counts each accredited provider group separately" do
      create_list(:course, 2, provider:, accrediting_provider: nil)
      create(:course, provider:, accrediting_provider: create(:accredited_provider, provider_name: "Other University"))

      get_courses

      expect(response.parsed_body.css(".app-table--courses__count").map { |count| count.text.strip })
        .to eq(["2 courses", "1 course"])
    end

    it "reflects the filters" do
      create(:course, :primary, provider:, accrediting_provider: nil)
      create(:course, :secondary, provider:, accrediting_provider: nil)

      get_courses(level: %w[primary])

      expect(response.parsed_body.css(".app-table--courses__count").text.strip).to eq("1 course")
    end
  end

  describe "the course information column under filtering" do
    def course_information
      response.parsed_body.css(".app-table--courses__course-information").text
    end

    it "keeps a field that varies across the whole list when the list is filtered to one value" do
      create(:course, :fee, provider:, accrediting_provider: nil, name: "Fee course")
      create(:course, :apprenticeship, provider:, accrediting_provider: nil, name: "Apprenticeship course")

      get_courses(funding: %w[fee])

      expect(course_names).to include("Fee course")
      expect(course_names).not_to include("Apprenticeship course")
      expect(course_information).to include("Fee-paying")
    end

    it "keeps a field hidden that is uniform across the whole list" do
      create(:course, :primary, :fee, provider:, accrediting_provider: nil, name: "Primary course")
      create(:course, :secondary, :fee, provider:, accrediting_provider: nil, name: "Secondary course")

      get_courses(level: %w[primary])

      expect(course_names).to include("Primary course")
      expect(course_information).not_to include("Fee-paying")
    end
  end
end
