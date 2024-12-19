# frozen_string_literal: true

module Publish
  module Providers
    module AccreditedPartnerships
      class ChecksController < PublishController
        def show
          provider_partnership_form
        end

        def update
          @partnership = provider.accredited_partnerships.build(accredited_provider: provider_partnership_form.accredited_provider, description: provider_partnership_form.description)

          if @partnership.save
            notify_accredited_provider_users

            redirect_to publish_provider_recruitment_cycle_accredited_partnerships_path(@provider.provider_code, @provider.recruitment_cycle_year), flash: { success: 'Accredited partnership added' }
          else
            render :show
          end
        end

        private

        def provider_partnership_form
          @provider_partnership_form ||= ProviderPartnershipForm.new(current_user, provider)
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
