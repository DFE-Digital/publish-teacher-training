# frozen_string_literal: true

module TitleBar
  class View < ViewComponent::Base
    attr_accessor :title, :current_user

    def initialize(title:, current_user:, provider:)
      super
      @title = title
      @current_user = current_user
      @provider = provider
    end

    def change_organisation_link
      govuk_link_to t("change_organisation"), root_path({ recruitment_cycle_year: params[:recruitment_cycle_year] }), class: "title-bar-link inline govuk-link--no-visited-state title-bar-inline-item title-bar-item-separator"
    end

    def change_cycle_link(provider)
      govuk_link_to t("page_titles.rollover.change_cycle"), publish_provider_path(code: provider), class: "title-bar-link inline govuk-link--no-visited-state"
    end

    def current_recruitment_cycle?
      params[:recruitment_cycle_year].to_i == Settings.current_recruitment_cycle_year
    end

    def next_recruitment_cycle?
      params[:recruitment_cycle_year].to_i == Settings.current_recruitment_cycle_year + 1
    end

    def rollover_active?
      Settings.features.rollover.can_edit_current_and_next_cycles == true
    end

    def multiple_providers_or_admin?(current_user)
      current_user.providers.where(recruitment_cycle: RecruitmentCycle.current).count > 1 || current_user.admin?
    end

    def current_recruitment_cycle_year
      Settings.current_recruitment_cycle_year - 1
    end

    def next_recruitment_cycle_year
      Settings.current_recruitment_cycle_year
    end
  end
end
