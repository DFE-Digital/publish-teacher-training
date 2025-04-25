# frozen_string_literal: true

module Publish
  module Providers
    module AccreditedPartnerships
      class ChecksController < ApplicationController
        def show
          @partnership = provider.accredited_partnerships.build(accredited_provider:)

          if @partnership.invalid?
            redirect_to search_publish_provider_recruitment_cycle_accredited_providers_path(provider.provider_code, recruitment_cycle.year), flash: { error: { message: "#{accredited_provider.name_and_code} partnership already exists" } }
          end
        end

        def update
          @partnership = provider.accredited_partnerships.build(accredited_provider:)

          if @partnership.save
            notify_accredited_provider_users

            flash[:success_with_body] = { "title" => t(".added"), "body" => accredited_provider.provider_name }
            redirect_to publish_provider_recruitment_cycle_accredited_partnerships_path(@provider.provider_code, @provider.recruitment_cycle_year)
          else
            flash[:error] = { "message" => @partnership.errors[:accredited_provider].first }
            render :show
          end
        end

      private

        def accredited_provider
          @accredited_provider = Provider.in_cycle(provider.recruitment_cycle).accredited.find(params[:accredited_provider_id])
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
