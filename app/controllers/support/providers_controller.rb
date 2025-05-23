# frozen_string_literal: true

module Support
  class ProvidersController < ApplicationController
    before_action :clear_form_stashes, only: :index
    before_action :set_provider, only: %i[show edit update]

    def index
      @pagy, @providers = pagy ProvidersQuery.call(params:)
    end

    def show; end
    def edit; end

    def update
      update_form = UpdateProviderForm.new(@provider, attributes: update_provider_params)

      if update_form.save
        redirect_to support_recruitment_cycle_provider_path(@provider.recruitment_cycle_year, @provider), flash: { success: t("support.flash.updated", resource: "Provider") }
      else
        render :edit
      end
    end

  private

    def set_provider
      @provider = recruitment_cycle.providers.find(params[:id])
    end

    def update_provider_params
      params.expect(
        provider: %i[
          provider_name
          provider_type
          ukprn
          urn
          accredited
          accredited_provider_number
        ],
      )
    end

    def clear_form_stashes
      return unless flash.key?(:success)

      [
        ProviderForm.new(current_user, recruitment_cycle:),
        ProviderContactForm.new(current_user),
      ].each(&:clear_stash)
    end
  end
end
