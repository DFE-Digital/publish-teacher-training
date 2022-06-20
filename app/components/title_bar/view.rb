# frozen_string_literal: true

module TitleBar
  class View < ViewComponent::Base
    attr_accessor :title

    def initialize(title:, provider:)
      super
      @title = title
      @provider = provider
    end

    def change_organisation_link
      govuk_link_to t("change_organisation"), root_path, class: "title-bar-link inline govuk-link--no-visited-state title-bar-inline-item"
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

    def current_recruitment_cycle_year
      Settings.current_recruitment_cycle_year - 1
    end

    def next_recruitment_cycle_year
      Settings.current_recruitment_cycle_year
    end
  end
end
