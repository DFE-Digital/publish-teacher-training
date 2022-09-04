module Publish
  module Providers
    class VisasController < PublishController
      def edit
        authorize(provider, :edit?)

        @provider_visa_form = ProviderVisaForm.new(provider)
      end

      def student_edit
        authorize(provider, :edit?)

        @provider_student_visa_form = ProviderStudentVisaForm.new(provider)
      end

      def skilled_worker_edit
        authorize(provider, :edit?)

        @provider_skilled_worker_visa_form = ProviderSkilledWorkerVisaForm.new(provider)
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

      def student_update
        authorize(provider, :update?)

        @provider_student_visa_form = ProviderStudentVisaForm.new(provider, params: provider_student_visa_params)

        if @provider_student_visa_form.save!
          flash[:success] = I18n.t("success.visa_changes")

          redirect_to details_publish_provider_recruitment_cycle_path(
            provider.provider_code,
            recruitment_cycle.year,
          )
        else
          render :student_edit
        end
      end

      def skilled_worker_update
        authorize(provider, :update?)

        @provider_skilled_worker_visa_form = ProviderSkilledWorkerVisaForm.new(provider, params: provider_skilled_worker_visa_params)

        if @provider_skilled_worker_visa_form.save!
          flash[:success] = I18n.t("success.visa_changes")

          redirect_to details_publish_provider_recruitment_cycle_path(
            provider.provider_code,
            recruitment_cycle.year,
          )
        else
          render :skilled_worker_edit
        end
      end

    private

      def provider_visa_params
        return { can_sponsor_student_visa: nil } if params[:publish_provider_visa_form].blank?

        params.require(:publish_provider_visa_form).permit(*ProviderVisaForm::FIELDS).transform_values do |value|
          ActiveModel::Type::Boolean.new.cast(value)
        end
      end

      def provider_student_visa_params
        return { can_sponsor_student_visa: nil } if params[:publish_provider_student_visa_form].blank?

        params.require(:publish_provider_student_visa_form).permit(*ProviderStudentVisaForm::FIELDS).transform_values do |value|
          ActiveModel::Type::Boolean.new.cast(value)
        end
      end

      def provider_skilled_worker_visa_params
        return { can_sponsor_skilled_worker_visa: nil } if params[:publish_provider_skilled_worker_visa_form].blank?

        params.require(:publish_provider_skilled_worker_visa_form).permit(*ProviderSkilledWorkerVisaForm::FIELDS).transform_values do |value|
          ActiveModel::Type::Boolean.new.cast(value)
        end
      end
    end
  end
end
