# frozen_string_literal: true

module TitleBar
  class View < ViewComponent::Base
    attr_accessor :title, :current_user

    delegate :multiple_providers_or_admin?, to: :current_user

    def initialize(title:, current_user:, provider:)
      super
      @title = title
      @current_user = current_user
      @provider = provider
    end

  private

    def change_organisation_link
      govuk_link_to t("change_organisation"), root_path({ recruitment_cycle_year: }), class: "title-bar-link govuk-link--no-visited-state title-bar-inline-item title-bar-item-separator"
    end

    def change_cycle_link(provider)
      govuk_link_to t("page_titles.rollover.change_cycle"), publish_provider_path(code: provider), class: "title-bar-link govuk-link--no-visited-state"
    end

    def current_recruitment_cycle?
      recruitment_cycle_year == Settings.current_recruitment_cycle_year
    end

    def next_recruitment_cycle?
      recruitment_cycle_year == Settings.current_recruitment_cycle_year + 1
    end

    def recruitment_cycle_year
      (params[:recruitment_cycle_year] || params[:year] || session[:recruitment_cycle_year]).to_i
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

    def recruitment_label
      if current_recruitment_cycle?
        "- #{current_recruitment_cycle_year} to #{next_recruitment_cycle_year} - current"
      elsif next_recruitment_cycle?
        "- #{current_recruitment_cycle_year + 1} to #{next_recruitment_cycle_year + 1}"
      end
    end
  end
end
