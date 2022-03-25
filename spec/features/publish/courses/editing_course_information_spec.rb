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

  #scenario "copying course information with no courses available" do
    #then_i_should_see_the_related_sidebar
    #and_i_should_see_the_reuse_content
  #end

  context "copying content from another course" do
    let!(:course_2) do
      create(
        :course, :with_accrediting_provider,
        #provider: provider_for_copy_from_list,
        name: "Biology",
        enrichments: [course_2_enrichment]
      )
    end

    let!(:course_3) do
      create :course,
            name: "Biology",
            #provider: provider_for_copy_from_list,
            enrichments: [ course_3_enrichment]
    end

    let!(:provider_for_copy_from_list) do
      create :provider, :accredited_body,
             accrediting_provider_enrichments: [{
              "UcasProviderCode" => provider.provider_code,
              "Description" => Faker::Lorem.sentence,
            }]
            #courses: [course_2, course_3],
            #provider_code: provider.provider_code
    end

    let(:course_2_enrichment) do
      build(:course_enrichment,
            about_course: "Course 2 - About course",
            interview_process: "Course 2 - Interview process",
            how_school_placements_work: "Course 2 - How teaching placements work"
      )
    end

    let(:course_3_enrichment) do
      build(:course_enrichment,
            about_course: "Course 3 - About course",
      )
    end

    scenario "all fields get copied if all are present" do
      publish_course_information_page.load(
        provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
      )
      #binding.pry
      publish_course_information_page.copy_content.copy(course_2)
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

  def then_i_should_see_the_related_sidebar
    expect(publish_course_information_page).to have_related_sidebar
  end

  def and_i_should_see_the_reuse_content
    publish_course_information_page.related_sidebar.within do |sidebar|
      expect(sidebar).to have_use_content
    end
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
