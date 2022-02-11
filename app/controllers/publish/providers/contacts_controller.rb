module Publish
  module Providers
    class ContactsController < PublishController
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
        params.require(:publish_provider_contact_form).permit(*ProviderContactForm::FIELDS)
      end

      def provider
        @provider ||= Provider.find_by!(recruitment_cycle: recruitment_cycle, provider_code: params[:provider_code])
      end

      def recruitment_cycle
        cycle_year = params[:recruitment_cycle_year] || params[:year] || Settings.current_recruitment_cycle_year

        @recruitment_cycle ||= RecruitmentCycle.find_by!(year: cycle_year)
      end
    end
  end
end
