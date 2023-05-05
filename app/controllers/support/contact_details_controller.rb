# frozen_string_literal: true

module Support
  class ContactDetailsController < SupportController
    def edit
      # provider
      @provider_contact_form = ContactDetailsForm.new(provider)
    end

    def update
      @provider_contact_form = ContactDetailsForm.new(provider, params: update_provider_params)

      if @provider_contact_form.save!

        redirect_to support_recruitment_cycle_provider_path(provider.recruitment_cycle_year, provider), flash: { success: t('support.flash.updated', resource: 'Provider') }
      else
        render :edit
      end

      # if provider.update(update_provider_params)
      #  redirect_to support_recruitment_cycle_provider_path(provider.recruitment_cycle_year, provider), flash: { success: t('support.flash.updated', resource: 'Provider') }
      # else
      #  render :edit
      # end
    end

    private

    def provider
      @provider ||= recruitment_cycle.providers.find(params[:provider_id])
    end

    def update_provider_params
      params.require(:support_contact_details_form).permit(:email,
                                                           :telephone,
                                                           :website,
                                                           :address1,
                                                           :address2,
                                                           :address3,
                                                           :town,
                                                           :address4,
                                                           :postcode)
    end
  end
end
