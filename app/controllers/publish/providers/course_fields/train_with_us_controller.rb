# frozen_string_literal: true

module Publish
  module Providers
    module CourseFields
      class TrainWithUsController < ApplicationController
        def edit
          @about_form = WhyTrainWithUsForm.new(
            provider,
            redirect_params:,
            course_code: params[:course_code],
          )
        end

        def update
          authorize provider, :update?

          @about_form = WhyTrainWithUsForm.new(
            provider,
            params: provider_params,
            redirect_params:,
            course_code: params.dig(param_form_key, :course_code),
          )

          if @about_form.save!
            redirect_to @about_form.update_success_path
            flash[:success] = I18n.t("success.published") if redirect_params.all? { |_k, v| v.blank? }
          else
            @errors = @about_form.errors.messages
            render :edit
          end
        end

      private

        def redirect_params
          params.fetch(param_form_key, params).slice(
            :goto_preview,
            :goto_provider,
            :goto_about_us,
          ).permit!.to_h
        end

        def param_form_key = :publish_why_train_with_us_form

        def provider_params
          params
            .require(param_form_key)
            .except(:goto_preview, :course_code, :goto_provider, :goto_about_us)
            .permit(
              *WhyTrainWithUsForm::FIELDS,
              accredited_partners: %i[provider_name provider_code description],
            )
        end
      end
    end
  end
end
