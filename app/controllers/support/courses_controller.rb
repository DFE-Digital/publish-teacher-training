# frozen_string_literal: true

module Support
  class CoursesController < ApplicationController
    def index
      @pagy, @courses = pagy(provider.courses.order(:name))
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "Provider not found"
      redirect_to support_recruitment_cycle_providers_path
    end

    def edit
      @edit_course_form = Support::EditCourseForm.new(course)
    end

    def update
      @edit_course_form = Support::EditCourseForm.new(course)
      @edit_course_form.assign_attributes(update_course_params)

      if @edit_course_form.save
        redirect_to support_recruitment_cycle_provider_courses_path(provider.recruitment_cycle_year, provider), flash: { success: t("support.flash.updated", resource: "Course") }
      else
        render :edit
      end
    end

  private

    def provider
      @provider ||= recruitment_cycle.providers.find(params[:provider_id])
    end

    def course
      @course ||= provider.courses.find(params[:id])
    end

    def update_course_params
      params.expect(
        support_edit_course_form: [*EditCourseForm::FIELDS,
                                   :'start_date(3i)',
                                   :'start_date(2i)',
                                   :'start_date(1i)',
                                   :'applications_open_from(3i)',
                                   :'applications_open_from(2i)',
                                   :'applications_open_from(1i)',
                                   :is_send,
                                   :can_sponsor_student_visa,
                                   :can_sponsor_skilled_worker_visa,
                                   :accredited_provider_code],
      ).transform_keys { |key| date_field_to_attribute(key) }
    end

    def date_field_to_attribute(key)
      case key
      when "start_date(3i)" then "start_date_day"
      when "start_date(2i)" then "start_date_month"
      when "start_date(1i)" then "start_date_year"
      when "applications_open_from(3i)" then "applications_open_from_day"
      when "applications_open_from(2i)" then "applications_open_from_month"
      when "applications_open_from(1i)" then "applications_open_from_year"
      else key
      end
    end
  end
end
