# frozen_string_literal: true

class TitleBar < ViewComponent::Base
  attr_accessor :title, :current_user

  delegate :multiple_providers_or_admin?, to: :current_user

  def initialize(title:, current_user:, provider:)
    super
    @title = title
    @current_user = current_user
    @provider = provider
  end

private

  def change_items
    [*(change_cycle_link if rollover_active?), *(change_organisation_link if multiple_providers_or_admin?)]
  end

  def reversed_change_items
    change_items.reverse
  end

  def change_organisation_link
    govuk_link_to t("change_organisation"), root_path, class: "title-bar__link govuk-link--no-visited-state"
  end

  def change_cycle_link
    govuk_link_to t("page_titles.rollover.change_cycle"), publish_provider_path(code: @provider, switcher: true), class: "title-bar__link govuk-link--no-visited-state"
  end

  def current_recruitment_cycle?
    recruitment_cycle_year == Settings.current_recruitment_cycle_year
  end

  def next_recruitment_cycle?
    recruitment_cycle_year == Settings.current_recruitment_cycle_year + 1
  end

  def recruitment_cycle_year
    (params[:recruitment_cycle_year] || params[:year] || session[:cycle_year]).to_i
  end

  def rollover_active?
    RecruitmentCycle.next_editable_cycles?
  end

  def current_recruitment_cycle_year
    Settings.current_recruitment_cycle_year - 1
  end

  def next_recruitment_cycle_year
    Settings.current_recruitment_cycle_year
  end

  def recruitment_label
    if current_recruitment_cycle?
      "- #{current_recruitment_cycle_year} to #{next_recruitment_cycle_year} - current"
    elsif next_recruitment_cycle?
      "- #{current_recruitment_cycle_year + 1} to #{next_recruitment_cycle_year + 1}"
    end
  end
end
