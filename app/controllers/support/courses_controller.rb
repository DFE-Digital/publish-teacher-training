module Support
  class CoursesController < SupportController
    def index
      @courses = provider.courses.order(:name).page(params[:page] || 1)
      render layout: "provider_record"
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "Provider not found"
      redirect_to support_providers_path
    end

    def edit
      @edit_course_form = Support::EditCourseForm.new(course)
    end

    def update
      @edit_course_form = Support::EditCourseForm.new(course)
      @edit_course_form.assign_attributes(update_course_params)

      if @edit_course_form.save
        redirect_to support_provider_courses_path(provider), flash: { success: t("support.flash.updated", resource: "Course") }
      else
        render :edit
      end
    end

  private

    def provider
      @provider ||= RecruitmentCycle.current.providers.find(params[:provider_id])
    end

    def course
      @course ||= provider.courses.find(params[:id])
    end

    def update_course_params
      params.require(:support_edit_course_form).permit(
        *EditCourseForm::FIELDS,
        :"start_date(3i)", :"start_date(2i)", :"start_date(1i)"
      ).transform_keys { |key| start_date_field_to_attribute(key) }
    end

    def start_date_field_to_attribute(key)
      case key
      when "start_date(3i)" then "start_date_day"
      when "start_date(2i)" then "start_date_month"
      when "start_date(1i)" then "start_date_year"
      else key
      end
    end
  end
end
