module Support
  class CoursesController < SupportInterfaceController
    def index
      @courses = provider.courses.order(:name).page(params[:page] || 1)
      render layout: "provider_record"
    end

  private

    def provider
      @provider ||= RecruitmentCycle.current.providers.find(params[:provider_id])
    end
  end
end
