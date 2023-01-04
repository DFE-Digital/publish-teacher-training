module Find
  class SwitcherController < ApplicationController
    def cycles; end

    def update
      new_cycle = params[:find_change_cycle_form][:cycle_schedule_name]
      SiteSetting.set(name: "cycle_schedule", value: new_cycle)
      flash[:success] = I18n.t("cycles.updated")
      redirect_to find_cycles_path
    end
  end
end
