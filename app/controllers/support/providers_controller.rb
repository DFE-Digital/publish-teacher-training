# frozen_string_literal: true

module Support
  class ProvidersController < SupportController
    def index
      [ProviderForm.new(current_user, recruitment_cycle:), ProviderContactForm.new(current_user)].each(&:clear_stash) if flash.key?(:success)
      @pagy, @providers = pagy(filtered_providers)
    end

    def show
      provider
      render layout: 'provider_record'
    end

    def edit
      provider
    end

    def update
      if provider.update(update_provider_params)
        redirect_to support_recruitment_cycle_provider_path(provider.recruitment_cycle_year, provider), flash: { success: t('support.flash.updated', resource: 'Provider') }
      else
        render :edit
      end
    end

    def users
      @pagy, @users = pagy(provider.users.order(:last_name))
      render layout: 'provider_record'
    end

    private

    def filtered_providers
      @filtered_providers ||= Support::Filter.call(model_data_scope: find_providers, filter_params:)
    end

    def find_providers
      recruitment_cycle.providers.order(:provider_name).includes(:recruitment_cycle)
    end

    def filter_params
      @filter_params ||= params.except(:commit, :recruitment_cycle_year).permit(:provider_search, :course_search, :page, :accrediting_provider, provider_type: %i[scitt university lead_partner])
    end

    def provider
      @provider ||= recruitment_cycle.providers.find(params[:id])
    end

    def update_provider_params
      params.require(:provider).permit(:provider_name,
                                       :provider_type,
                                       :ukprn,
                                       :urn,
                                       :accrediting_provider, :accredited_provider_number)
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
                                                                        town
                                                                        address4
                                                                        postcode],
                                                   organisations_attributes: %i[name]).merge(recruitment_cycle:)
    end
  end
end
