# frozen_string_literal: true

require "rails_helper"

feature "Editing course information" do
  before do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    when_i_visit_the_course_information_page
  end

  scenario "i can update some information about the course" do
    and_i_set_information_about_the_course
    and_i_submit
    then_i_should_see_a_success_message
    and_the_course_information_is_updated
  end

  scenario "copying course information with no courses available" do
    then_i_should_see_the_reuse_content
  end

  context "copying content from another course" do
    let!(:course_2) do
      create(
        :course,
        provider: provider,
        name: "Biology",
        enrichments: [course_2_enrichment],
      )
    end

    let!(:course_3) do
      create :course,
             provider: provider,
             name: "Biology",
             enrichments: [course_3_enrichment]
    end

    let(:course_2_enrichment) do
      build(:course_enrichment,
            about_course: "Course 2 - About course",
            interview_process: "Course 2 - Interview process",
            how_school_placements_work: "Course 2 - How teaching placements work")
    end

    let(:course_3_enrichment) do
      build(:course_enrichment,
            about_course: "Course 3 - About course",
            interview_process: "",
            how_school_placements_work: "")
    end

    scenario "all fields get copied if all are present" do
      publish_course_information_page.load(
        provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
      )
      publish_course_information_page.copy_content.copy(course_2)

      [
        "Your changes are not yet saved",
        "About the course",
        "Interview process",
        "How school placements work",
      ].each do |name|
        expect(publish_course_information_page.copy_content_warning).to have_content(name)
      end

      expect(publish_course_information_page.about_course.value).to eq(course_2_enrichment.about_course)
      expect(publish_course_information_page.interview_process.value).to eq(course_2_enrichment.interview_process)
      expect(publish_course_information_page.school_placements.value).to eq(course_2_enrichment.how_school_placements_work)
    end

    scenario "only fields with values are copied if the source is incomplete" do
      publish_course_information_page.load(
        provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course_2.course_code,
      )
      publish_course_information_page.copy_content.copy(course_3)

      [
        "Your changes are not yet saved",
        "About the course",
      ].each do |name|
        expect(publish_course_information_page.copy_content_warning).to have_content(name)
      end

      [
        "Interview process",
        "How school placements work",
      ].each do |name|
        expect(publish_course_information_page.copy_content_warning).not_to have_content(name)
      end

      expect(publish_course_information_page.about_course.value).to eq(course_3_enrichment.about_course)
      expect(publish_course_information_page.interview_process.value).to eq(course_2_enrichment.interview_process)
      expect(publish_course_information_page.school_placements.value).to eq(course_2_enrichment.how_school_placements_work)
    end
  end

  scenario "updating with invalid data" do
    and_i_submit_with_invalid_data
    then_i_should_see_an_error_message
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists(enrichments: [build(:course_enrichment, :published)])
  end

  def then_i_should_see_the_reuse_content
    expect(publish_course_information_page).to have_use_content
  end

  def when_i_visit_the_course_information_page
    publish_course_information_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def and_i_set_information_about_the_course
    @about_course = "This is a new description"
    @interview_process = "This is a new interview process"
    @school_placements = "This is a new school placements"

    publish_course_information_page.about_course.set(@about_course)
    publish_course_information_page.interview_process.set(@interview_process)
    publish_course_information_page.school_placements.set(@school_placements)
  end

  def and_i_submit_with_invalid_data
    publish_course_information_page.about_course.set(nil)
    and_i_submit
  end

  def and_i_submit
    publish_course_information_page.submit.click
  end

  def then_i_should_see_a_success_message
    expect(page).to have_content(I18n.t("success.saved"))
  end

  def and_the_course_information_is_updated
    enrichment = course.reload.enrichments.find_or_initialize_draft

    expect(enrichment.about_course).to eq(@about_course)
    expect(enrichment.interview_process).to eq(@interview_process)
    expect(enrichment.how_school_placements_work).to eq(@school_placements)
  end

  def then_i_should_see_an_error_message
    expect(publish_course_information_page.error_messages).to include(
      I18n.t("activemodel.errors.models.publish/course_information_form.attributes.about_course.blank"),
    )
  end

  def provider
    @provider ||= @current_user.providers.first
  end
end
