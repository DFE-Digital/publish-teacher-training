# frozen_string_literal: true

module Find
  class SwitcherController < ApplicationController
    skip_before_action :redirect_to_cycle_has_ended_if_find_is_down

    def cycles; end

    def update
      new_cycle = params[:find_change_cycle_form][:cycle_schedule_name]
      SiteSetting.set(name: 'cycle_schedule', value: new_cycle)
      flash[:success] = I18n.t('cycles.updated')
      redirect_to find_cycles_path
    end
  end
end
