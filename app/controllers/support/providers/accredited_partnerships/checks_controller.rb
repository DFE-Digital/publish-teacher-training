# frozen_string_literal: true

module Support
  module Providers
    module AccreditedPartnerships
      class ChecksController < ApplicationController
        def show
          accredited_provider_form
        end

        def update
          @partnership = provider.accredited_partnerships.build(accredited_provider_id: accredited_provider_form.accredited_provider_id,
                                                                description: accredited_provider_form.description)
          if @partnership.save
            notify_accredited_provider_users

            redirect_to support_recruitment_cycle_provider_accredited_partnerships_path(
              recruitment_cycle.year, provider.id
            ), flash: { success: t(".added") }
          else
            render :show
          end
        end

      private

        def accredited_provider_form
          @accredited_provider_form ||= ProviderPartnershipForm.new(current_user, new_partnership)
        end

        def provider
          @provider ||= recruitment_cycle.providers.find(params[:provider_id])
        end

        def new_partnership
          @new_partnership = provider.accredited_partnerships.build
        end

        def partner
          Provider.find(accredited_provider_form.accredited_provider_id)
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
