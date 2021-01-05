module GIAS
  class PostcodesController < GIAS::ApplicationController
    def index
      @pagy, @postcodes = pagy_array((
                                       GIASEstablishment.pluck(:postcode) +
                                       Provider.pluck(:postcode) +
                                       Site.pluck(:postcode)
                                     ).map(&:strip).map(&:upcase).sort)
    end

    def show
      @postcode = params[:postcode]
      @establishments = GIASEstablishment.where(postcode: params[:postcode])
      @recruitment_cycle = RecruitmentCycle.current
      @providers = @recruitment_cycle.providers.where(postcode: params[:postcode])
      @sites = @recruitment_cycle.sites.where(postcode: params[:postcode])
    end
  end
end
