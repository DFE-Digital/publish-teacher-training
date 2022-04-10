module Publish
  class RecruitmentCyclesController < PublishController
    def show
      @recruitment_cycle = RecruitmentCycle.find_by(year: params[:year])
      # @provider = Provider.where(recruitment_cycle_year: params[:year])
      #  .find(params[:provider_code])
      #  .first
      @provider ||= recruitment_cycle.providers.find_by!(provider_code: params[:provider_code] || params[:code])
      authorize provider, :show?
      unless @provider.rolled_over?
        redirect_to publish_provider_path(@provider.provider_code)
      end
    end

    # def provider
    #  @provider ||= recruitment_cycle.providers.find_by!(provider_code:  params[:provider_code] || #params[:code])
    # end
  end
end
