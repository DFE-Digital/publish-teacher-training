# frozen_string_literal: true

module Support
  class RecruitmentCyclesController < ApplicationController
    before_action :set_recruitment_cycle, :authorize_recruitment_cycle, only: %i[show edit update review_rollover confirm_rollover]
    before_action :set_rollover_progress_query, only: %i[show review_rollover confirm_rollover]

    def index
      @recruitment_cycles = RecruitmentCycle.order(year: :desc)
    end

    def new
      @support_recruitment_cycle_form = RecruitmentCycleForm.new
    end

    def create
      @support_recruitment_cycle_form = RecruitmentCycleForm.new(recruitment_cycle_form_params)

      if @support_recruitment_cycle_form.valid?
        RecruitmentCycleCreationService.call(
          year: @support_recruitment_cycle_form.year,
          application_start_date: @support_recruitment_cycle_form.application_start_date,
          application_end_date: @support_recruitment_cycle_form.application_end_date,
          available_in_publish_from: @support_recruitment_cycle_form.available_in_publish_from,
        )

        redirect_to support_recruitment_cycles_path, flash: { success: t(".added") }
      else
        render :new
      end
    end

    def edit
      @support_recruitment_cycle_form = RecruitmentCycleForm.new(
        year: @recruitment_cycle.year,
        application_start_date: @recruitment_cycle.application_start_date,
        application_end_date: @recruitment_cycle.application_end_date,
        available_in_publish_from: @recruitment_cycle.available_in_publish_from,
      )
    end

    def update
      @support_recruitment_cycle_form = RecruitmentCycleForm.new(recruitment_cycle_form_params)

      if @support_recruitment_cycle_form.valid?(:update)
        @recruitment_cycle.update!(
          year: @support_recruitment_cycle_form.year,
          application_start_date: @support_recruitment_cycle_form.application_start_date,
          application_end_date: @support_recruitment_cycle_form.application_end_date,
          available_in_publish_from: @support_recruitment_cycle_form.available_in_publish_from,
        )

        redirect_to support_recruitment_cycle_path(@recruitment_cycle), flash: { success: t(".updated") }
      else
        render :edit
      end
    end

    def show; end

    def review_rollover
      @review_rollover_form = ReviewRolloverForm.new
    end

    def confirm_rollover
      @review_rollover_form = ReviewRolloverForm.new(params.fetch(:support_review_rollover_form, {}).permit(:confirmation))

      if @review_rollover_form.valid?
        RolloverJob.perform_later(@recruitment_cycle.id)

        redirect_to support_recruitment_cycle_path(@recruitment_cycle, confirmed: true), flash: { success: t(".rollover_confirmed") }
      else
        render :review_rollover
      end
    end

  private

    def recruitment_cycle_form_params
      params
        .expect(
          support_recruitment_cycle_form: %i[
            year
            application_start_date
            application_end_date
            available_in_publish_from
          ],
        )
    end

    def set_recruitment_cycle
      @recruitment_cycle = RecruitmentCycle.find(params[:id])
    end

    def authorize_recruitment_cycle
      authorize @recruitment_cycle
    end

    def set_rollover_progress_query
      @rollover_progress_query = RolloverProgressQuery.new(target_cycle: @recruitment_cycle)
    end
  end
end
