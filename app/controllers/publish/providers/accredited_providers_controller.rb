# frozen_string_literal: true

module Publish
  module Providers
    class AccreditedProvidersController < PublishController
      helper_method :query, :search_result_title_component

      def index
        authorize_provider
        provider
      end

      def new
        authorize_provider
        provider
        @accredited_provider_search_form = AccreditedProviderSearchForm.new
      end

      def create
        authorize_provider

        @accredited_provider_search_form = AccreditedProviderSearchForm.new(query:)

        if @accredited_provider_search_form.valid?
          @accredited_provider_select_form = AccreditedProviderSelectForm.new
          @accredited_provider_search = AccreditedProviders::SearchService.call(query:)

          render :results
        else
          provider
          render :new
        end
      end

      def provider
        @provider ||= recruitment_cycle.providers.find_by(provider_code: params[:provider_code] || params[:code])
      end

      def query
        # Order is important here so the query persists across each step.
        @accredited_provider_search_form&.query || accredited_provider_search_params[:query] || accredited_provider_select_params[:query]
      end

      def accredited_provider_search_params
        return {} unless params.key?(:accredited_provider_search_form)

        params.require(:accredited_provider_search_form).permit(*AccreditedProviderSearchForm::FIELDS)
      end

      def accredited_provider_select_params
        return {} unless params.key?(:accredited_provider_select_form)

        params.require(:accredited_provider_select_form).permit(*AccreditedProviderSelectForm::FIELDS, *AccreditedProviderSearchForm::FIELDS)
      end

      def search_result_title_component
        @search_result_title_component ||= SearchResultTitleComponent.new(
          query:,
          results_limit: @accredited_provider_search.limit,
          results_count: @accredited_provider_search.providers.unscope(:limit).count,
          return_path: publish_provider_recruitment_cycle_accredited_providers_path,
          search_resource: 'accredited provider',
          caption_text: "Add accredited provider - #{provider.name_and_code}"
        )
      end

      def authorize_provider
        authorize(provider)
      end
    end
  end
end
