# frozen_string_literal: true

module Publish
  class ProvidersController < ApplicationController
    include RecruitmentCycleHelper
    include GotoPreview

    def index
      authorize :provider, :index?

      page = (params[:page] || 1).to_i
      per_page = 30
      @pagy, @providers = pagy(providers.order(:provider_name), page:, items: per_page)

      render "publish/providers/no_providers", status: :forbidden if @providers.blank?
      redirect_to publish_provider_path(@providers.first.provider_code) if @providers.count == 1
    end

    def suggest
      skip_authorization

      @provider_list = providers
                       .provider_search(params[:query])
                       .limit(10)
                       .map { |provider| { code: provider.provider_code, name: provider.provider_name } }
      render json: @provider_list
    end

    def show
      @rollover_period = RolloverPeriod.new(current_user:)

      unless @rollover_period.active?
        redirect_to publish_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year)
      end
    end

    def details
      redirect_to_contact_page_with_ukprn_error if provider.ukprn.blank?
      @errors = flash[:error_summary]
      flash.delete(:error_summary)
    end

    def about
      @about_form = AboutYourOrganisationForm.new(
        provider,
        redirect_params:,
        course_code: params[:course_code],
      )
    end

    def update
      authorize provider, :update?

      @about_form = AboutYourOrganisationForm.new(
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
        render :about
      end
    end

    def search
      skip_authorization

      provider_query = params[:query]

      if provider_query.blank?
        flash[:error] = { id: "provider-error", message: "Name or provider code" }
        return redirect_to publish_root_path
      end

      provider_code = provider_query
                      .split
                      .last
                      .gsub(/[()]/, "")

      redirect_to publish_provider_path(provider_code)
    end

  private

    def providers
      @providers ||= if current_user.admin?
                       RecruitmentCycle.current.providers
                     else
                       RecruitmentCycle.current.providers.where(id: current_user.providers)
                     end
    end

    def redirect_to_contact_page_with_ukprn_error
      flash[:error] = { id: "publish-provider-contact-form-ukprn-field", message: "Please enter a UKPRN before continuing" }

      redirect_to contact_publish_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle_year)
    end

    def provider_params
      params
        .require(param_form_key)
        .except(:goto_preview, :course_code, :goto_provider, :goto_training_with_disabilities)
        .permit(
          *AboutYourOrganisationForm::FIELDS,
          accredited_partners: %i[provider_name provider_code description],
        )
    end

    def param_form_key = :publish_about_your_organisation_form

    def redirect_params
      params.fetch(param_form_key, params).slice(
        :goto_preview,
        :goto_provider,
        :goto_training_with_disabilities,
      ).permit!.to_h
    end
  end
end
