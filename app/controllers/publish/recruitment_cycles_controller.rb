module Publish
  class RecruitmentCyclesController < PublishController
    def show
      authorize provider, :show?

      # @recruitment_cycle = RecruitmentCycle.find_by(year: params[:year])
      @provider ||= recruitment_cycle.providers.find_by!(provider_code: params[:provider_code] || params[:code])

      unless @provider.rolled_over?
        redirect_to publish_provider_path(@provider.provider_code)
      end
    end
  end
end
