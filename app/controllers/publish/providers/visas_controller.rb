module Publish
  module Providers
    class VisasController < PublishController
      def edit
        authorize(provider, :edit?)

        @provider_visa_form = ProviderVisaForm.new(provider)
      end

      def update
        authorize(provider, :update?)

        @provider_visa_form = ProviderVisaForm.new(provider, params: provider_visa_params)

        if @provider_visa_form.save!
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

      def provider_visa_params
        return { can_sponsor_student_visa: nil } if params[:publish_provider_visa_form].blank?

        params.require(:publish_provider_visa_form).permit(*ProviderVisaForm::FIELDS).transform_values do |value|
          ActiveModel::Type::Boolean.new.cast(value)
        end
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
