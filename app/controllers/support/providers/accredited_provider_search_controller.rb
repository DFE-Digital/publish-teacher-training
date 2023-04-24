# frozen_string_literal: true

module Support
  module Providers
    class AccreditedProviderSearchController < SupportController
      helper_method :query, :search_result_title_component

      def new
        provider
        @accredited_provider_search_form = AccreditedProviderSearchForm.new
      end

      def create
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

      def update
        @accredited_provider_select_form = AccreditedProviderSelectForm.new(provider_id: accredited_provider_select_params[:provider_id])

        if @accredited_provider_select_form.valid?
          redirect_to support_recruitment_cycle_provider_accredited_providers_path
        else
          @accredited_provider_search = AccreditedProviders::SearchService.call(query:)
          render :results
        end
      end

      private

      def query
        # Order is important here so the query persists across each step.
        @accredited_provider_search_form&.query || accredited_provider_search_params[:query] || accredited_provider_select_params[:query]
      end

      def provider
        @provider ||= recruitment_cycle.providers.find(params[:provider_id])
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
          return_path: search_support_recruitment_cycle_provider_accredited_providers_path,
          search_resource: 'accredited provider',
          caption_text: "Add accredited provider - #{provider.name_and_code}"
        )
      end
    end
  end
end
