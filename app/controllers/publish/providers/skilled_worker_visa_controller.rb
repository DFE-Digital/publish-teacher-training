module Publish
  module Providers
    class SkilledWorkerVisaController < PublishController
      def edit
        authorize(provider, :edit?)

        @provider_skilled_worker_visa_form = ProviderSkilledWorkerVisaForm.new(provider)
      end

      def update
        authorize(provider, :update?)

        @provider_skilled_worker_visa_form = ProviderSkilledWorkerVisaForm.new(provider, params: provider_skilled_worker_visa_params)

        if @provider_skilled_worker_visa_form.save!
          flash[:success] = I18n.t("success.visa_changes")

          redirect_to details_publish_provider_recruitment_cycle_path(
            provider.provider_code,
            recruitment_cycle.year,
          )
        else
          render :edit
        end
      end

    private

      def provider_skilled_worker_visa_params
        return { can_sponsor_skilled_worker_visa: nil } if params[:publish_provider_skilled_worker_visa_form].blank?

        params.require(:publish_provider_skilled_worker_visa_form).permit(*ProviderSkilledWorkerVisaForm::FIELDS).transform_values do |value|
          ActiveModel::Type::Boolean.new.cast(value)
        end
      end
    end
  end
end
