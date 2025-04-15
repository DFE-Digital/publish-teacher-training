# frozen_string_literal: true

module Support
  class RecruitmentCyclesController < ApplicationController
    def index
      @recruitment_cycles = RecruitmentCycle.order(year: :desc)
    end

    def new
      @support_recruitment_cycle_form = RecruitmentCycleForm.new
    end

    def show
      @recruitment_cycle = RecruitmentCycle.find(params[:id])
    end

    def create
      @support_recruitment_cycle_form = RecruitmentCycleForm.new(recruitment_cycle_form_params)

      if @support_recruitment_cycle_form.valid?
        RecruitmentCycleCreationService.call(
          year: @support_recruitment_cycle_form.year,
          application_start_date: @support_recruitment_cycle_form.application_start_date,
          application_end_date: @support_recruitment_cycle_form.application_end_date,
        )

        redirect_to support_recruitment_cycles_path, flash: { success: t(".added") }
      else
        render :new
      end
    end

    def edit
      @recruitment_cycle = RecruitmentCycle.find(params[:id])

      @support_recruitment_cycle_form = RecruitmentCycleForm.new(
        year: @recruitment_cycle.year,
        application_start_date: @recruitment_cycle.application_start_date,
        application_end_date: @recruitment_cycle.application_end_date,
      )
    end

    def update
      @recruitment_cycle = RecruitmentCycle.find(params[:id])
      @support_recruitment_cycle_form = RecruitmentCycleForm.new(recruitment_cycle_form_params)

      if @support_recruitment_cycle_form.valid?(:update)
        @recruitment_cycle.update!(
          year: @support_recruitment_cycle_form.year,
          application_start_date: @support_recruitment_cycle_form.application_start_date,
          application_end_date: @support_recruitment_cycle_form.application_end_date,
        )

        redirect_to support_recruitment_cycle_path(@recruitment_cycle), flash: { success: t(".updated") }
      else
        render :edit
      end
    end

  private

    def recruitment_cycle_form_params
      params
        .expect(
          support_recruitment_cycle_form: %i[year
                                             application_start_date
                                             application_end_date],
        )
    end
  end
end
