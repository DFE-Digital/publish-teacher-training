# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Viewing recruitment cycles", service: :publish do
  include DfESignInUserHelper
  let(:provider) { create(:provider) }
  let(:user) { create(:user, :admin, providers: [provider]) }
  let!(:previous_recruitment_cycle) { find_or_create(:recruitment_cycle, :previous) }

  before do
    sign_in_system_test(user:)
  end

  scenario "I view all recruitment cycles" do
    given_i_visit_support_settings
    when_i_click_recruitment_cycles
    then_i_see_the_current_recruitment_cycle
    then_i_see_the_past_recruitment_cycles
  end

  def given_i_visit_support_settings
    visit support_settings_path
  end

  def when_i_click_recruitment_cycles
    click_link_or_button "Recruitment Cycles"
  end

  def then_i_see_the_current_recruitment_cycle
    first_row = first(:css, ".govuk-table tbody tr", visible: true)

    within(first_row) do
      expect(page).to have_text(RecruitmentCycle.current.year)
      expect(page).to have_text(RecruitmentCycle.current.application_start_date.to_fs(:govuk_date))
      expect(page).to have_text(RecruitmentCycle.current.application_end_date.to_fs(:govuk_date))
      expect(page).to have_css(".govuk-tag.govuk-tag--green", text: "Current")
    end
  end

  def then_i_see_the_past_recruitment_cycles
    second_row = all(:css, ".govuk-table tbody tr", visible: true)[1]

    within(second_row) do
      expect(page).to have_text("2024")
      expect(page).to have_text(previous_recruitment_cycle.application_start_date.to_fs(:govuk_date))
      expect(page).to have_text(previous_recruitment_cycle.application_end_date.to_fs(:govuk_date))
      expect(page).to have_css(".govuk-tag.govuk-tag--grey", text: "Past")
    end
  end
end
