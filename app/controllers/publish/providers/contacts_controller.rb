# frozen_string_literal: true

module Publish
  module Providers
    class ContactsController < ApplicationController
      def edit
        authorize(provider, :edit?)

        @provider_contact_form = ProviderContactForm.new(provider)
      end

      def update
        authorize(provider, :update?)

        @provider_contact_form = ProviderContactForm.new(provider, params: provider_contact_params)

        if @provider_contact_form.save!
          flash[:success] = I18n.t("success.published")

          redirect_to details_publish_provider_recruitment_cycle_path(
            provider.provider_code,
            recruitment_cycle.year,
          )
        else
          render :edit
        end
      end

    private

      def provider_contact_params
        params.expect(publish_provider_contact_form: [*ProviderContactForm::FIELDS])
      end
    end
  end
end
