# frozen_string_literal: true

class SupportTitleBar < ViewComponent::Base
  attr_reader :current_user

  def initialize(current_user:)
    super()

    @current_user = current_user
  end

private

  def show_cycle_switcher?
    rollover_active? && (provider_section? || onboarding_section?)
  end

  def title
    label = "Recruitment cycle #{selected_cycle_year - 1} to #{selected_cycle_year}"
    label += " - current" if selected_cycle_year == Find::CycleTimetable.current_year
    label
  end

  def change_cycle_link
    govuk_link_to t("page_titles.rollover.change_cycle"), support_root_path, class: "title-bar__link govuk-link--no-visited-state"
  end

  def change_items
    [change_cycle_link]
  end

  def rollover_active?
    RolloverPeriod.active?(current_user:)
  end

  def provider_section?
    request.path.start_with?("/support/#{params[:recruitment_cycle_year]}/providers")
  end

  def onboarding_section?
    request.path.start_with?("/support/providers-onboarding-form-requests")
  end

  def selected_cycle_year
    params[:recruitment_cycle_year].presence&.to_i || Find::CycleTimetable.current_year
  end
end
