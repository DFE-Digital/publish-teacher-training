# frozen_string_literal: true

module TitleBar
  class View < ViewComponent::Base
    attr_accessor :title

    def initialize(title:)
      super
      @title = title
    end

    def link
      govuk_link_to t("change_organisation"), root_path, class: "title-bar-link inline govuk-link--no-visited-state"
    end

    def current_recruitment_cycle?
      params[:recruitment_cycle_year].to_i == Settings.current_recruitment_cycle_year
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
