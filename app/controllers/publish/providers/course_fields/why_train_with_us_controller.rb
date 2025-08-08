# frozen_string_literal: true

module Publish
  module Providers
    module CourseFields
      class WhyTrainWithUsController < ApplicationController
        def edit
          @train_with_us_form = WhyTrainWithUsForm.new(
            provider,
            redirect_params:,
            course_code: params[:course_code],
          )
        end

        def update
          authorize provider, :update?

          @train_with_us_form = WhyTrainWithUsForm.new(
            provider,
            params: provider_params,
            redirect_params:,
            course_code: params.dig(param_form_key, :course_code),
          )

          if @train_with_us_form.save!
            redirect_to @train_with_us_form.update_success_path
            flash[:success] = I18n.t("success.published") if redirect_params.all? { |_k, v| v.blank? }
          else
            @errors = @train_with_us_form.errors.messages
            render :edit
          end
        end

      private

        def redirect_params
          params.fetch(param_form_key, params).slice(
            :goto_provider,
          ).permit!.to_h
        end

        def param_form_key = :publish_why_train_with_us_form

        def provider_params
          params
            .require(param_form_key)
            .except(:course_code, :goto_provider)
            .permit(
              *WhyTrainWithUsForm::FIELDS,
              accredited_partners: %i[provider_name provider_code description],
            )
        end
      end
    end
  end
end
