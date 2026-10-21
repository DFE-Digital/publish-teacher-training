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

  def get_courses(provider, **params)
    login_user(create(:user, :admin))
    get "/support/#{provider.recruitment_cycle_year}/providers/#{provider.id}/courses", params:
  end

  def headers
    response.parsed_body.css("th").map { |header| header.text.strip }
  end

  it "shows the course count, primary age range and the course information that varies" do
    provider = create(:provider)
    cycle_year = provider.recruitment_cycle.year.to_i
    create(
      :course,
      provider:,
      name: "Primary",
      level: :primary,
      age_range_in_years: "5_to_11",
      funding: "fee",
      qualification: :pgce_with_qts,
      study_mode: :full_time,
      start_date: Time.zone.local(cycle_year, 9, 1),
    )
    create(
      :course,
      :secondary,
      provider:,
      name: "Physics",
      funding: "apprenticeship",
      qualification: :qts,
      study_mode: :full_time_or_part_time,
      start_date: Time.zone.local(cycle_year + 1, 8, 1),
    )

    get_courses(provider)

    expect(response.body).to include("2 courses")
    expect(headers).to eq(["Course", "Course information", "Status", ""])

    primary = response.parsed_body.css(".course-row").find { |row| row.text.include?("Primary") }
    expect(primary.at_css(".name a")[:class]).to include("govuk-!-font-weight-bold")
    expect(primary.at_css(".govuk-hint").text.strip).to eq("Ages 5 to 11")
    expect(primary.at_css(".course-information").text).to include("Fee-paying", "QTS with PGCE", "Full time", "September #{cycle_year}")
    expect(primary.at_css(".course-information span")[:class]).to include("govuk-!-margin-bottom-0")

    physics = response.parsed_body.css(".course-row").find { |row| row.text.include?("Physics") }
    expect(physics.at_css(".govuk-hint")).to be_nil
    expect(physics.at_css(".course-information").text).to include("Apprenticeship", "QTS", "Full time or part time", "August #{cycle_year + 1}")
  end

  it "does not show an age range for further education" do
    provider = create(:provider)
    create(:course, :without_validation, provider:, name: "Further education", level: :further_education, age_range_in_years: "14_to_19")

    get_courses(provider)

    expect(response.parsed_body.at_css(".course-row .govuk-hint")).to be_nil
  end

  it "hides course information when it is the same for every course" do
    provider = create(:provider)
    shared = {
      provider:,
      funding: "fee",
      qualification: :qts,
      study_mode: :full_time,
      start_date: Time.zone.local(provider.recruitment_cycle.year.to_i, 9, 1),
    }
    create(:course, **shared, name: "Biology")
    create(:course, **shared, name: "Chemistry")

    get_courses(provider)

    expect(headers).not_to include("Course information")
    expect(response.body).not_to include("Fee-paying")
    expect(response.body).to include("2 courses")
  end

  it "hides the accredited provider column when no course has one" do
    provider = create(:provider)
    create(:course, provider:, accrediting_provider: nil)

    get_courses(provider)

    expect(headers).not_to include("Accredited provider")
    expect(response.body).to include("1 course")
  end

  it "names the accredited provider column and shows it when a course has one" do
    provider = create(:provider)
    accredited_provider = create(:accredited_provider, recruitment_cycle: provider.recruitment_cycle, provider_name: "University of Chester")
    create(:course, provider:, accredited_provider_code: accredited_provider.provider_code)

    get_courses(provider)

    expect(headers).to eq(["Course", "Accredited provider", "Status", ""])
    accredited_provider_header = response.parsed_body.css("th").find { |header| header.text.strip == "Accredited provider" }
    expect(accredited_provider_header[:class]).to include("govuk-!-width-one-quarter")
    expect(response.body).to include("University of Chester")
  end

  it "shows only the course information fields that vary" do
    provider = create(:provider)
    accredited_provider = create(:accredited_provider, recruitment_cycle: provider.recruitment_cycle)
    shared = {
      provider:,
      funding: "fee",
      qualification: :qts,
      start_date: Time.zone.local(provider.recruitment_cycle.year.to_i, 9, 1),
      accredited_provider_code: accredited_provider.provider_code,
    }
    create(:course, **shared, name: "Biology", study_mode: :full_time)
    create(:course, **shared, name: "Chemistry", study_mode: :part_time)

    get_courses(provider)

    expect(headers).to eq(["Course", "Accredited provider", "Course information", "Status", ""])

    biology = response.parsed_body.css(".course-row").find { |row| row.text.include?("Biology") }
    information = biology.at_css(".course-information").text

    expect(information).to include("Full time")
    expect(information).not_to include("Fee-paying")
    expect(information).not_to include("QTS")
    expect(information).not_to include("September")
  end

  it "hides course information for a single course and still shows its age range" do
    provider = create(:provider)
    create(:course, provider:, name: "Primary", level: :primary, age_range_in_years: "5_to_11")

    get_courses(provider)

    expect(response.body).to include("1 course")
    expect(headers).not_to include("Course information")
    expect(response.parsed_body.at_css(".course-row .govuk-hint").text.strip).to eq("Ages 5 to 11")
  end

  it "keeps a difference on another page visible, and counts every course" do
    provider = create(:provider)
    shared = {
      provider:,
      funding: "fee",
      qualification: :qts,
      study_mode: :full_time,
      start_date: Time.zone.local(provider.recruitment_cycle.year.to_i, 9, 1),
    }
    10.times { |index| create(:course, **shared, name: sprintf("Course %02d", index + 1)) }
    create(:course, **shared, name: "Course 11", funding: "salary")

    get_courses(provider)

    expect(response.body).to include("11 courses")
    expect(response.parsed_body.css(".course-row").size).to eq(10)
    expect(headers).to include("Course information")

    first_row = response.parsed_body.at_css(".course-row .course-information").text
    expect(first_row).to include("Fee-paying")
    expect(first_row).not_to include("QTS")
    expect(first_row).not_to include("Full time")
    expect(first_row).not_to include("September")
  end

  it "keeps the accredited provider column when only some courses have one" do
    provider = create(:provider)
    accredited_provider = create(:accredited_provider, recruitment_cycle: provider.recruitment_cycle, provider_name: "University of Chester")
    create(:course, provider:, name: "Accredited", accredited_provider_code: accredited_provider.provider_code)
    create(:course, provider:, name: "Self accredited", accrediting_provider: nil)

    get_courses(provider)

    expect(headers).to include("Accredited provider")

    accredited = response.parsed_body.css(".course-row").find { |row| row.text.include?("Accredited (") }
    self_accredited = response.parsed_body.css(".course-row").find { |row| row.text.include?("Self accredited") }

    expect(accredited.text).to include("University of Chester")
    expect(self_accredited.text).not_to include("University of Chester")
  end
end
