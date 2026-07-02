# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Course preview", service: :publish, travel: mid_cycle(2027) do
  include Rails.application.routes.url_helpers

  scenario "Adding missing salary fee details from course preview" do
    given_i_am_authenticated(user: user_with_a_salaried_course)
    when_i_visit_the_publish_course_preview_page
    and_i_click_link_or_button("Enter details about fees")
    and_i_fill_in_the_salary_fee_details
    and_i_submit_the_form
    then_i_am_redirected_back_to_the_preview_page
    and_i_see_the_salary_fee_details_content
  end

private

  def user_with_a_salaried_course
    @provider = create(:provider, recruitment_cycle:)
    @course = create(
      :course,
      :salary_type_based,
      provider:,
      enrichments: [build(:course_enrichment, :initial_draft, salary_fee_details: nil)],
    )
    create(:user, providers: [@provider])
  end

  def when_i_visit_the_publish_course_preview_page
    visit preview_publish_provider_recruitment_cycle_course_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      code: course.course_code,
    )
  end

  def and_i_fill_in_the_salary_fee_details
    fill_in "Give details about any fees or other costs that the trainee might have to pay (optional)", with: "Trainees may need to pay for a DBS check"
  end

  def and_i_submit_the_form
    click_button "Update fees"
  end

  def then_i_am_redirected_back_to_the_preview_page
    expect(page).to have_current_path("/publish/organisations/#{@provider.provider_code}/#{@provider.recruitment_cycle_year}/courses/#{@course.course_code}/preview")
  end

  def and_i_see_the_salary_fee_details_content
    expect(page).to have_content("Trainees may need to pay for a DBS check")
  end

  alias_method :and_i_click_link_or_button, :click_link_or_button

  def provider
    @provider ||= @current_user.providers.first
  end

  def recruitment_cycle
    @recruitment_cycle ||= Current.recruitment_cycle
  end

  def course
    @course ||= provider.courses.first
  end
end
