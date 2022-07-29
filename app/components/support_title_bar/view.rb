# frozen_string_literal: true

module SupportTitleBar
  class View < ViewComponent::Base
  private

    def title
      if current_recruitment_cycle?
        "Recruitment cycle #{current_recruitment_cycle_year} to #{next_recruitment_cycle_year} - current"
      else
        "Recruitment cycle #{current_recruitment_cycle_year + 1} to #{next_recruitment_cycle_year + 1}"
      end
    end

    def change_cycle_link
      govuk_link_to t("page_titles.rollover.change_cycle"), support_path, class: "title-bar__link govuk-link--no-visited-state"
    end

    def change_items
      [change_cycle_link]
    end

    def rollover_active?
      Settings.features.rollover.can_edit_current_and_next_cycles == true
    end

    def recruitment_cycle_year
      params[:recruitment_cycle_year].to_i
    end

    def current_recruitment_cycle?
      recruitment_cycle_year == Settings.current_recruitment_cycle_year
    end

    def next_recruitment_cycle?
      recruitment_cycle_year == Settings.current_recruitment_cycle_year + 1
    end

    def current_recruitment_cycle_year
      Settings.current_recruitment_cycle_year - 1
    end

    def next_recruitment_cycle_year
      Settings.current_recruitment_cycle_year
    end

    def support_index_page
      request.path == "/support"
    end

  end
end
