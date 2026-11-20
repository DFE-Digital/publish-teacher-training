# frozen_string_literal: true

module Publish
  module Providers
    class AccreditedPartnershipsController < ApplicationController
      include ReturningToSupport

      helper_method :accredited_provider_id

      def index
        @provider_partnerships = @provider.accredited_partnerships
      end

      def show
        @provider_partnership = provider.accredited_partnerships.find_by!(accredited_provider: partner)
        @accredited_provider = @provider_partnership.accredited_provider
        @training_provider = @provider_partnership.training_provider
      end

      def delete
        @provider_partnership = provider.accredited_partnerships.find_by(accredited_provider: partner)
        cannot_delete
      end

      def destroy
        if cannot_delete
          redirect_to delete_publish_provider_recruitment_cycle_accredited_partnership_path(
            provider.provider_code,
            provider.recruitment_cycle_year,
            params[:accredited_provider_code],
            **support_return_params,
          )
          return
        end

        @provider_partnership = provider.accredited_partnerships.find_by(accredited_provider: partner)

        # Already removed, for example by a second submit of the form.
        if @provider_partnership.nil?
          redirect_to publish_or_support_accredited_partnerships_path
          return
        end

        if @provider_partnership.destroy
          set_removed_flash
          redirect_to publish_or_support_accredited_partnerships_path
        else
          render :delete, status: :unprocessable_content
        end
      end

    private

      def set_removed_flash
        if returning_to_support?
          flash[:success_with_body] = {
            "title" => t(".removed"),
            "body" => ERB::Util.html_escape(@provider_partnership.accredited_provider.provider_name),
          }
        else
          flash[:success] = t(".removed")
        end
      end

      def cannot_delete
        @cannot_delete ||= provider.courses.exists?(accredited_provider_code: params[:accredited_provider_code])
      end

      def provider
        @provider = recruitment_cycle.providers.find_by(provider_code: params[:provider_code])
      end

      def partner
        recruitment_cycle.providers.find_by(provider_code: params[:accredited_provider_code])
      end
    end
  end
end
