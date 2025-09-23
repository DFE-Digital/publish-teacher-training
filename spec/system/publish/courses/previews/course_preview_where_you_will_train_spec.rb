# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Course preview", service: :publish do
  include Rails.application.routes.url_helpers

  before do
    allow(FeatureFlag).to receive(:active?)
    allow(FeatureFlag).to receive(:active?).with(:long_form_content).and_return(true)
  end

  scenario "Adding missing Where you will train from course preview" do
    given_i_am_authenticated(user: user_with_no_course_enrichments)
    when_i_visit_the_publish_course_preview_page
    and_i_click_link_or_button("Enter details about where you will train")
    and_i_fill_in_the_where_will_you_train_inputs
    and_i_submit_the_form
    then_i_am_redirected_back_to_the_preview_page
    and_i_see_the_where_you_will_train_content
  end

private

  def user_with_no_course_enrichments
    @provider = create(:provider, recruitment_cycle:)

    @course = create(:course, :secondary, :with_accrediting_provider, provider:)

    @provider.accredited_partnerships.create(accredited_provider: @course.accrediting_provider)

    create(:user, providers: [@provider])
  end

  def when_i_visit_the_publish_course_preview_page
    visit preview_publish_provider_recruitment_cycle_course_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      code: course.course_code,
    )
  end

  def and_i_fill_in_the_where_will_you_train_inputs
    fill_in "How do you decide which schools to place trainees in?", with: "text1"
    fill_in "How much time will they spend in each school?", with: "text2"
  end

  def and_i_submit_the_form
    click_button "Update where you will train"
  end

  def then_i_am_redirected_back_to_the_preview_page
    expect(page).to have_current_path("/publish/organisations/#{@provider.provider_code}/#{@recruitment_cycle.year}/courses/#{@course.course_code}/preview")
  end

  def and_i_see_the_where_you_will_train_content
    expect(page).to have_content("text1")
    expect(page).to have_content("text2")
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

  def accrediting_provider
    @accrediting_provider ||= course.accrediting_provider
  end
end
