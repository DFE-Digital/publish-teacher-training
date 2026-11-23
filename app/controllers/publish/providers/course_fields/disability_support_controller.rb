# frozen_string_literal: true

module Publish
  module Providers
    module CourseFields
      class DisabilitySupportController < ApplicationController
        def edit
          @disability_support_form = DisabilitySupportForm.new(
            provider,
            redirect_params:,
            course_code: params[:course_code],
          )
        end

        def update
          authorize provider, :update?

          @disability_support_form = DisabilitySupportForm.new(
            provider,
            params: provider_params,
            redirect_params:,
            course_code: params.dig(param_form_key, :course_code),
          )

          if @disability_support_form.save!
            redirect_to @disability_support_form.update_success_path
            flash[:success] = I18n.t("success.published") if redirect_params.all? { |_k, v| v.blank? }
          else
            @errors = @disability_support_form.errors.messages
            render :edit
          end
        end

      private

        def redirect_params
          params.fetch(param_form_key, params).slice(
            :goto_provider,
            :goto_training_with_disabilities,
          ).permit!.to_h
        end

        def param_form_key = :publish_disability_support_form

        def provider_params
          params
            .require(param_form_key)
            .except(:course_code, :goto_train_with_disability, :goto_provider)
            .permit(
              *DisabilitySupportForm::FIELDS,
              accredited_partners: %i[provider_name provider_code description],
            )
        end
      end
    end
  end
end
