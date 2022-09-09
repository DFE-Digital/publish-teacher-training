module Publish
  module Providers
    class StudentVisaController < PublishController
      def edit
        authorize(provider, :edit?)

        @provider_student_visa_form = ProviderStudentVisaForm.new(provider)
      end

      def update
        authorize(provider, :update?)

        @provider_student_visa_form = ProviderStudentVisaForm.new(provider, params: provider_student_visa_params)

        if @provider_student_visa_form.save!
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

      def provider_student_visa_params
        return { can_sponsor_student_visa: nil } if params[:publish_provider_student_visa_form].blank?

        params.require(:publish_provider_student_visa_form).permit(*ProviderStudentVisaForm::FIELDS).transform_values do |value|
          ActiveModel::Type::Boolean.new.cast(value)
        end
      end
    end
  end
end
