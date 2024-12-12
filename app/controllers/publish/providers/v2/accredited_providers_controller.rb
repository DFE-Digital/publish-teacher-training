# frozen_string_literal: true

module Publish
  module Providers
    module V2
      class AccreditedProvidersController < PublishController
        def index; end

        def new
          @provider_partnership = provider.accredited_partnerships.build(accredited_provider: Provider.find(params[:accredited_provider_id]))
        end

        def create
          @provider_partnership = provider.accredited_partnerships.build(description: partnership_params[:description], accredited_provider: Provider.find(partnership_params[:accredited_provider_id]))

          @accredited_provider_form = AccreditedProviderForm.new(current_user, provider, params: partnership_params)

          if @provider_partnership.valid? && @accredited_provider_form.stash
            redirect_to check_publish_provider_recruitment_cycle_accredited_providers_path(@provider.provider_code, recruitment_cycle.year)
          else
            render :new
          end
        end

        private

        def provider
          @provider = recruitment_cycle.providers.find_by(provider_code: params[:provider_code])
        end

        def partnership_params
          params.require(:provider_partnership).permit(:accredited_provider_id, :description)
        end
      end
    end
  end
end
