# frozen_string_literal: true

module Publish
  module Providers
    module V2
      module AccreditedProviders
        class ChecksController < PublishController
          def show
            accredited_provider_form
          end

          def update
            @partnership = provider.accredited_partnerships.build(accredited_provider: accredited_provider_form.accredited_provider, description: accredited_provider_form.description)

            if @partnership.save
              notify_accredited_provider_users

              redirect_to publish_provider_recruitment_cycle_accredited_providers_path(@provider.provider_code, @provider.recruitment_cycle_year), flash: { success: 'Accredited provider added' }
            else
              render :show
            end
          end

          private

          def accredited_provider_form
            @accredited_provider_form ||= AccreditedProviderForm.new(current_user, provider)
          end

          def notify_accredited_provider_users
            @partnership.accredited_provider.users.each do |user|
              ::Users::OrganisationMailer.added_as_an_organisation_to_training_partner(
                recipient: user,
                provider: provider,
                accredited_provider: @partnership.accredited_provider
              ).deliver_later
            end
          end
        end
      end
    end
  end
end
