module Support
  class ProvidersController < SupportController
    def index
      @providers = filtered_providers
    end

    def new
      @provider = Provider.new
      @provider.sites.build
      @provider.organisations.build
    end

    def create
      @provider = Provider.new(create_provider_params)
      if @provider.save
        redirect_to support_provider_path(provider), flash: { success: "Provider was successfully created" }
      else
        render :new
      end
    end

    def show
      provider
      render layout: "provider_record"
    end

    def edit
      provider
    end

    def update
      if provider.update(update_provider_params)
        redirect_to support_provider_path(provider), flash: { success: t("support.flash.updated", resource: "Provider") }
      else
        render :edit
      end
    end

    def users
      @users = provider.users.order(:last_name).page(params[:page] || 1)
      render layout: "provider_record"
    end

  private

    def filtered_providers
      @filtered_providers ||= Support::Filter.call(model_data_scope: find_providers, filter_params: filter_params)
    end

    def find_providers
      RecruitmentCycle.current.providers.order(:provider_name).includes(:courses, :users)
    end

    def filter_params
      @filter_params ||= params.except(:commit).permit(:provider_search, :course_search, :page)
    end

    def provider
      @provider ||= Provider.find(params[:id])
    end

    def update_provider_params
      params.require(:provider).permit(:provider_name, :provider_type)
    end

    def create_provider_params
      params.require(:provider).permit(:provider_name,
                                       :provider_code,
                                       :provider_type,
                                       :urn,
                                       :recruitment_cycle_id,
                                       :email,
                                       :ukprn,
                                       :telephone, sites_attributes: %i[code
                                                                        urn
                                                                        location_name
                                                                        address1
                                                                        address2
                                                                        address3
                                                                        address4
                                                                        postcode],
                                                   organisations_attributes: %i[name]).merge(recruitment_cycle: RecruitmentCycle.current_recruitment_cycle)
    end
  end
end
