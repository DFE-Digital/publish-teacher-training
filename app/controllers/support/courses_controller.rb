module Support
  class CoursesController < SupportController
    def index
      @courses = provider.courses.order(:name).page(params[:page] || 1)
      render layout: "provider_record"
    end

    def edit
      course
    end

    def update
      if course.update(update_course_params)
        redirect_to support_provider_courses_path(provider)
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
      params.require(:course).permit(:course_code, :name, :start_date)
    end
  end
end
