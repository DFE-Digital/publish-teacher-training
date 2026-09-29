# frozen_string_literal: true

module Publish
  class CoursesController < ApplicationController
    include ApplyRedirect

    decorates_assigned :course

    def index
      @filter_form = ::Publish::Courses::FilterForm.new(provider:, **course_filter_params)
      @course_list = ::Publish::CourseList.new(provider:, params: @filter_form.filter_params)
    end

    def show
      fetch_course

      authorize @course

      @errors = flash[:error_summary]
      flash.delete(:error_summary)
    end

    def details
      fetch_course

      if show_errors_on_publish?
        @course.valid?(:publish)
        @errors = format_publish_error_messages
      end

      authorize @course
    end

    def preview
      fetch_course
      @provider = provider
      @course = @course.decorate

      @enrichment = @course.latest_unpublished_enrichment || @course.enrichments.find_or_initialize_draft
      @apply_action_column_class = apply_action_column_class

      authorize @course
    end

    def publish
      fetch_course_with_latest_draft_enrichment_eager_loaded
      authorize @course

      if ::Courses::PublishService.new(course: @course, user: @current_user).call
        flash[:success] = render_flash_message_content

        redirect_to publish_provider_recruitment_cycle_course_path(
          @provider.provider_code,
          @course.recruitment_cycle_year,
          @course.course_code,
        )
      else
        @errors = format_publish_error_messages

        if @errors.key?(:sites)
          @current_tab = :details
          render :details
        else
          @current_tab = :description
          render :show
        end
      end
    end

  private

    # Mirrors Find::CoursesController#apply_action_column_class so the preview lays the
    # apply/save row out exactly as the live Find course page does.
    def apply_action_column_class
      if FeatureFlag.active?(:candidate_accounts) && Find::CycleTimetable.apply_deadline_passed
        "govuk-grid-column-full"
      elsif FeatureFlag.active?(:candidate_accounts)
        "govuk-grid-column-one-third-from-desktop"
      else
        "govuk-grid-column-one-half"
      end
    end

    def render_flash_message_content
      @course.scheduled? ? "Your course has been scheduled." : "Your course has been published."
    end

    def fetch_course_with_latest_draft_enrichment_eager_loaded
      @course = provider.courses.includes(
        :latest_draft_enrichment,
        subjects: [:financial_incentive],
        site_statuses: [:site],
      ).find_by!(course_code: params[:code])
    end

    def fetch_course
      @course = provider.courses.includes(
        :enrichments,
        subjects: [:financial_incentive],
        site_statuses: [:site],
      ).find_by!(course_code: params[:code])
    end

    def provider
      @provider ||= recruitment_cycle.providers.find_by!(provider_code: params[:provider_code])
    end

    def course_filter_params
      ::Publish::Courses::FilterParams.permit(params).to_h.symbolize_keys
    end

    def format_publish_error_messages
      @course.errors.messages.transform_values do |error_messages|
        error_messages.map { |message| message.gsub(/^\^/, "") }
      end
    end
  end
end
