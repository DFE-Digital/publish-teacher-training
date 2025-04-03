# frozen_string_literal: true

module Support
  class RecruitmentCyclesController < ApplicationController
    def index; end

    def new
      @support_recruitment_cycle_form = RecruitmentCycleForm.new
    end

    def create
      @support_recruitment_cycle_form = RecruitmentCycleForm.new(
        params
          .expect(
            support_recruitment_cycle_form: %i[year
                                               application_start_date
                                               application_end_date]
          )
      )

      if @support_recruitment_cycle_form.valid?
        RecruitmentCycleCreationService.call(
          year: @support_recruitment_cycle_form.year,
          application_start_date: @support_recruitment_cycle_form.application_start_date,
          application_end_date: @support_recruitment_cycle_form.application_end_date
        )

        redirect_to support_recruitment_cycles_path, flash: { success: t('.added') }
      else
        render :new
      end
    end
  end
end
