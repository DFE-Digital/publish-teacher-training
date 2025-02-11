# frozen_string_literal: true

module Publish
  module Providers
    class AccreditedPartnershipsController < ApplicationController
      helper_method :accredited_provider_id

      def index; end

      def new
        provider_partnership = provider.accredited_partnerships.build
        accredited_provider_id = params[:accredited_provider_id] || ProviderPartnershipForm.new(current_user, provider).accredited_provider_id
        provider_partnership.assign_attributes(accredited_provider_id:)

        if provider_partnership.valid?
          @provider_partnership_form = ProviderPartnershipForm.new(current_user, provider_partnership, params: { accredited_provider_id: })
        else
          redirect_to search_publish_provider_recruitment_cycle_accredited_providers_path(provider.provider_code, RecruitmentCycle.current.year), flash: { error: { message: "#{Provider.find(params[:accredited_provider_id]).name_and_code} partnership already exists" } }
        end
      end

      def edit
        provider_partnership = provider.accredited_partnerships.find_by(accredited_provider: partner)

        params = { accredited_provider_id: partner.id, description: provider_partnership.description }
        @provider_partnership_form = ProviderPartnershipForm.new(current_user, provider_partnership, params:)
      end

      def create
        @provider_partnership_form = ProviderPartnershipForm.new(current_user, @provider_partnership, params: partnership_params)

        if @provider_partnership_form.stash
          redirect_to check_publish_provider_recruitment_cycle_accredited_partnerships_path(@provider.provider_code, recruitment_cycle.year)
        else
          render :new
        end
      end

      def update
        @provider_partnership = provider.accredited_partnerships.find_by(accredited_provider_id: partner.id)
        @provider_partnership_form = ProviderPartnershipForm.new(current_user, @provider_partnership, params: partnership_params)

        if @provider_partnership_form.save!
          flash[:success] = t('.edit.updated')
          redirect_to publish_provider_recruitment_cycle_accredited_partnerships_path(@provider.provider_code, recruitment_cycle.year)
        else
          render :edit
        end
      end

      def delete
        @provider_partnership = provider.accredited_partnerships.find_by(accredited_provider: partner)
        cannot_delete
      end

      def destroy
        @partnership = provider.accredited_partnerships.find_by(accredited_provider_id: partner.id)

        if @partnership.destroy
          flash[:success] = t('.removed')
          redirect_to publish_provider_recruitment_cycle_accredited_partnerships_path(@provider.provider_code, recruitment_cycle.year)
        else
          render :delete
        end
      end

      private

      def cannot_delete
        @cannot_delete ||= provider.courses.exists?(accredited_provider_code: params[:accredited_provider_code])
      end

      def provider
        @provider = recruitment_cycle.providers.find_by(provider_code: params[:provider_code])
      end

      def partner
        recruitment_cycle.providers.find_by(provider_code: params[:accredited_provider_code])
      end

      def partnership_params
        params.expect(provider_partnership_form: %i[accredited_provider_id description])
      end
    end
  end
end
