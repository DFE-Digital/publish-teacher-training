# frozen_string_literal: true

module Publish
  module Providers
    class SchoolPlacementsController < ApplicationController
      def edit
        authorize(provider, :edit?)

        @provider = provider
      end

      def update
        authorize(provider, :update?)

        if @provider.update(provider_params)
          flash[:success] = I18n.t('success.published')

          redirect_to details_publish_provider_recruitment_cycle_path(
            provider.provider_code,
            recruitment_cycle.year
          )
        else
          render :edit
        end
      end

      private

      def provider_params
        params.expect(provider: [:selectable_school])
      end
    end
  end
end
