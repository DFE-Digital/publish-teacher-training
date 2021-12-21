module Support
  class ProvidersController < SupportController
    def index
      @providers = filtered_providers.page(params[:page] || 1)
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
        # The below code is to fix a mismatch of error messages
        # for invalid forms in the support console.
        @provider.errors.messages.each { |k, v|
          case k
          when :"sites.urn", :email, :telephone
            @provider.errors.messages[k] = v.first.gsub("^", "")
          else
            @provider.errors.messages[k] = "#{k.to_s.gsub(/.\.^?/, ' ').humanize} #{v.first}"
          end
        }
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
        redirect_to support_provider_path(provider)
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
      Support::Filter.call(model_data_scope: find_providers, filters: filters)
    end

    def find_providers
      RecruitmentCycle.current.providers.order(:provider_name).includes(:courses, :users)
    end

    def filters
      @filters ||= ProviderFilter.new(params: filter_params).filters
    end

    def filter_params
      params.permit(:provider_search, :course_search, :page, :commit)
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
