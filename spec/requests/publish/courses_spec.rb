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

    it "shows no active filters" do
      get_courses

      expect(response.parsed_body.css(".app-active-filters")).to be_empty
    end
  end

  describe "which filter groups are shown" do
    def filter_headings
      response.parsed_body.css(".app-c-filter-section__summary-heading").map { |heading| heading.text.strip }
    end

    it "shows every group when the courses vary on all of them" do
      create(:course, :published, :primary, :fee, provider:, application_status: :open, study_mode: :full_time,
                                                  qualification: :qts, start_date: Time.zone.local(2026, 9, 1), name: "A")
      create(:course, :draft_enrichment, :secondary, :salary, provider:, study_mode: :part_time,
                                                              qualification: :pgce_with_qts, start_date: Time.zone.local(2027, 1, 1), name: "B")

      get_courses

      expect(filter_headings).to eq(
        ["Status", "Education phase", "Fee or salary", "Qualification", "Full time or part time", "Start date"],
      )
    end

    it "hides the groups the courses do not vary on" do
      # Same status, funding, qualification, study mode and start date; only phase differs.
      create(:course, :without_validation, :primary, provider:, funding: "fee", qualification: :qts, study_mode: :full_time, start_date: Time.zone.local(2026, 9, 1))
      create(:course, :without_validation, :secondary, provider:, funding: "fee", qualification: :qts, study_mode: :full_time, start_date: Time.zone.local(2026, 9, 1))

      get_courses

      expect(filter_headings).to eq(["Education phase"])
    end

    context "when the courses vary on nothing" do
      before { create(:course, :without_validation, provider:, name: "Only course") }

      it "does not render the filter sidebar" do
        get_courses

        expect(response.parsed_body.css(".app-c-filter-section")).to be_empty
        expect(response.parsed_body.text).not_to include("Filter courses")
      end

      it "shifts the course list to the left at its usual width, without a sidebar column" do
        get_courses

        expect(response.parsed_body.css(".govuk-grid-column-one-third")).to be_empty
        expect(response.parsed_body.css(".govuk-grid-column-two-thirds")).to be_present
        expect(course_names).to include("Only course")
      end
    end
  end

  describe "filtering by start month" do
    let(:cycle_year) { provider.recruitment_cycle_year.to_i }

    before do
      create(:course, provider:, accrediting_provider: nil, name: "September course", start_date: Time.zone.local(cycle_year, 9, 1))
      create(:course, provider:, accrediting_provider: nil, name: "January course", start_date: Time.zone.local(cycle_year + 1, 1, 1))
    end

    it "offers only the months the courses start in" do
      get_courses

      expect(response.parsed_body.css("input[name='start_date[]']").map { |input| input[:value] })
        .to eq(["#{cycle_year}-09", "#{cycle_year + 1}-01"])
    end

    it "narrows the list by start month" do
      get_courses(start_date: ["#{cycle_year}-09"])

      expect(course_names).to include("September course")
      expect(course_names).not_to include("January course")
    end

    # No course starts then, so the month is not an option and the value is
    # dropped like any other unrecognised one, rather than emptying the list.
    it "ignores a start month no course starts in" do
      get_courses(start_date: ["#{cycle_year}-12"])

      expect(course_names).to include("September course", "January course")
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
