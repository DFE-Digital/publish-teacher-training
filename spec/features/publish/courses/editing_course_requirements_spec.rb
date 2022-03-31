# frozen_string_literal: true

require "rails_helper"

feature "Editing course requirements" do
  before do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    when_i_visit_the_course_requirements_page
  end

  scenario "i can update the requirements of the course" do
    then_i_should_see_the_reuse_content
    and_i_update_the_requirements
    and_i_submit
    then_i_should_see_a_success_message
    and_the_course_requirements_are_updated
  end

  context "copying content from another course" do
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
            personal_qualities: "Test personal qualities",
            other_requirements: "Test other requirements")
    end

    let(:course3_enrichment) do
      build(:course_enrichment,
            personal_qualities: "Test course 3",
            other_requirements: "")
    end

    scenario "all fields get copied if all are present" do
      when_i_visit_the_course_requirements_page
      publish_course_requirements_page.copy_content.copy(course2)

      [
        "Your changes are not yet saved",
        "Personal qualities",
        "Other requirements",
      ].each do |name|
        expect(publish_course_requirements_page.copy_content_warning).to have_content(name)
      end

      expect(publish_course_requirements_page.personal_qualities.value).to eq(course2_enrichment.personal_qualities)
      expect(publish_course_requirements_page.other_requirements.value).to eq(course2_enrichment.other_requirements)
    end

    scenario "missing fields do not get copied" do
      publish_course_requirements_page.load(
        provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course2.course_code,
      )
      publish_course_requirements_page.copy_content.copy(course3)

      [
        "Your changes are not yet saved",
        "Personal qualities",
      ].each do |name|
        expect(publish_course_requirements_page.copy_content_warning).to have_content(name)
      end

      [
        "other requirements",
      ].each do |name|
        expect(publish_course_requirements_page.copy_content_warning).not_to have_content(name)
      end

      expect(publish_course_requirements_page.personal_qualities.value).to eq(course3_enrichment.personal_qualities)
      # expect(publish_course_requirements_page.other_requirements.value).to eq(course2_enrichment.other_requirements)
    end
  end

  scenario "updating with invalid data" do
    and_i_submit_with_invalid_data
    then_i_should_see_an_error_message
  end

  def then_i_should_see_the_reuse_content
    expect(publish_course_requirements_page).to have_use_content
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists(enrichments: [build(:course_enrichment, :published)])
  end

  def when_i_visit_the_course_requirements_page
    publish_course_requirements_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def and_i_update_the_requirements
    @personal_qualities = "This is a new requirement"
    @other_requirements = "This is another new requirement"

    publish_course_requirements_page.personal_qualities.set(@personal_qualities)
    publish_course_requirements_page.other_requirements.set(@other_requirements)
  end

  def and_i_submit_with_invalid_data
    publish_course_requirements_page.personal_qualities.set(Faker::Lorem.sentence(word_count: 101))
    and_i_submit
  end

  def and_i_submit
    publish_course_requirements_page.submit.click
  end

  def then_i_should_see_a_success_message
    expect(page).to have_content(I18n.t("success.saved"))
  end

  def and_the_course_requirements_are_updated
    enrichment = course.reload.enrichments.find_or_initialize_draft

    expect(enrichment.personal_qualities).to eq(@personal_qualities)
    expect(enrichment.other_requirements).to eq(@other_requirements)
  end

  def then_i_should_see_an_error_message
    expect(publish_course_requirements_page.error_messages).to include(
      I18n.t("activemodel.errors.models.publish/course_requirement_form.attributes.personal_qualities.too_long"),
    )
  end

  def provider
    @current_user.providers.first
  end
end
