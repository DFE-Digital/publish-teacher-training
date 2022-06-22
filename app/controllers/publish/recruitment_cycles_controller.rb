module Publish
  class RecruitmentCyclesController < PublishController
    def show
      authorize provider, :show?

      @recruitment_cycle = RecruitmentCycle.find_by(year: params[:year])
      @provider ||= recruitment_cycle.providers.find_by!(provider_code: params[:provider_code] || params[:code])

      redirect_to publish_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year)
    end
  end
end
