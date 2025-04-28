# frozen_string_literal: true

module Support
  module Providers
    module AccreditedPartnerships
      class ChecksController < ApplicationController
        def show
          @partnership = provider.accredited_partnerships.build(accredited_provider: partner)

          if @partnership.invalid?
            redirect_to search_support_recruitment_cycle_provider_accredited_providers_path(provider_id: provider.id, recruitment_cycle_year: recruitment_cycle.year), flash: { error: { message: "#{partner.name_and_code} partnership already exists" } }
          end
        end

        def update
          @partnership = provider.accredited_partnerships.build(accredited_provider_id: params[:provider_partnership][:accredited_provider_id])

          if @partnership.save
            notify_accredited_provider_users
            flash[:success_with_body] = { "title" => t(".added"), "body" => @partnership.accredited_provider.provider_name }
            redirect_to support_recruitment_cycle_provider_accredited_partnerships_path(
              recruitment_cycle.year, provider.id
            )
          else
            render :show
          end
        end

      private

        def provider
          @provider ||= recruitment_cycle.providers.find(params[:provider_id])
        end

        def partner
          Provider.find(params[:accredited_provider_id])
        end

        def notify_accredited_provider_users
          @partnership.accredited_provider.users.each do |user|
            ::Users::OrganisationMailer.added_as_an_organisation_to_training_partner(
              recipient: user,
              provider: provider,
              accredited_provider: @partnership.accredited_provider,
            ).deliver_later
          end
        end
      end
    end
  end
end
