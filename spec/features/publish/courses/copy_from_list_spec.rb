# frozen_string_literal: true

require "rails_helper"

feature "Editing course information" do
  before do
    given_i_am_authenticated_as_an_accredited_provider_user
    and_there_is_an_accredited_course_i_want_to_edit
    when_i_visit_the_course_information_page
  end

  let!(:course2) do
    create(
      :course,
      provider: provider,
      name: "Biology",
      enrichments: [course2_enrichment],
    )
  end

  let!(:course3) do
    create :course,
           provider: provider,
           name: "Biology",
           enrichments: [course3_enrichment]
  end

  let(:course2_enrichment) do
    build(:course_enrichment,
          about_course: "Course 2 - About course",
          interview_process: "Course 2 - Interview process",
          how_school_placements_work: "Course 2 - How teaching placements work")
  end

  let(:course3_enrichment) do
    build(:course_enrichment,
          about_course: "Course 3 - About course",
          interview_process: nil,
          how_school_placements_work: "")
  end

  scenario "the course does not display its own name in the copy list" do
    publish_course_information_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )

    list_options = publish_course_information_page.copy_content.copy_options
    expect(Course.count).to eq 3
    expect(list_options.size).to eq 3
    expect(list_options.shift).to eq("Pick a course")
    expect(list_options.any? { |x| x[@course.name] }).to be_falsey
  end

  def given_i_am_authenticated_as_an_accredited_provider_user
    given_i_am_authenticated(user: create(:user, :with_accredited_provider))
  end

  def and_there_is_an_accredited_course_i_want_to_edit
    given_a_course_exists(:with_accrediting_provider, enrichments: [build(:course_enrichment, :published)])
  end

  def when_i_visit_the_course_information_page
    publish_course_information_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def provider
    @provider ||= @current_user.providers.first
  end
end