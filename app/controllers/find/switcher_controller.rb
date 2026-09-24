# frozen_string_literal: true

module Find
  class SwitcherController < ApplicationController
    skip_before_action :redirect_to_cycle_has_ended_if_find_is_down

    def cycles; end

    def update
      new_cycle = params[:find_change_cycle_form][:cycle_schedule_name]

      unless permitted_schedules.include?(new_cycle)
        flash[:warning] = "#{new_cycle} is not a recruitment cycle phase"
        return redirect_to find_cycles_path
      end

      SiteSetting.set(name: "cycle_schedule", value: new_cycle)
      SiteSetting.set(name: "deadline_banner", value: deadline_banner_wanted?.to_s)
      flash[:success] = I18n.t("cycles.updated")
      redirect_to find_cycles_path
    end

  private

    # The deadline banner belongs to the cycle that is ending, so it is offered
    # against `apply_open` alone. Any other option clears it rather than leaving
    # it armed for next time.
    def deadline_banner_wanted?
      form = params[:find_change_cycle_form]

      form[:cycle_schedule_name] == "apply_open" && form[:deadline_banner] == "1"
    end

    def permitted_schedules
      %w[real] + Find::CycleTimetable::SWITCHER_OPTIONS.keys.map(&:to_s)
    end
  end
end
