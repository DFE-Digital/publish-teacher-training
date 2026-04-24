# frozen_string_literal: true

module Publish
  class CourseWizardsController < ApplicationController
    CACHE_EXPIRY = 24.hours
    LOCAL_CACHE_STORE = ActiveSupport::Cache::MemoryStore.new

    before_action :authorize_course_creation
    before_action :set_wizard, except: [:new]

    helper_method def current_step
      @wizard.current_step
    end

    helper_method def current_step_name
      params[:step]&.to_sym || :level
    end

    def new
      return render_schools_messages unless provider.sites.any?

      redirect_to publish_provider_recruitment_cycle_course_wizard_path(
        provider_code: params[:provider_code],
        recruitment_cycle_year: params[:recruitment_cycle_year],
        step: :level,
        state_key:,
      )
    end

    def show; end

    def create
      update
    end

    def update
      if @wizard.save_current_step
        redirect_to @wizard.next_step_path
      else
        render :show
      end
    end

  private

    def authorize_course_creation
      authorize(provider, :can_create_course?)
    end

    def render_schools_messages
      flash[:error] = { id: "schools-error", message: "You need to create at least one school before creating a course" }

      redirect_to publish_provider_recruitment_cycle_schools_path(
        provider.provider_code,
        provider.recruitment_cycle_year,
      )
    end

    def set_wizard
      state_store = CourseWizard::StateStores::CourseWizard.new(
        repository: wizard_repository,
      )

      @wizard = CourseWizard.new(
        current_step: current_step_name,
        current_step_params: step_params,
        state_store:,
      ).tap do |wizard|
        wizard.recruitment_cycle_year = params[:recruitment_cycle_year]
        wizard.provider_code = params[:provider_code]
        wizard.state_key = state_key
      end
    end

    def state_key
      @state_key ||= params[:state_key]
    end

    def step_params
      params
    end

    def wizard_repository
      DfE::Wizard::Repository::Cache.new(
        cache: wizard_cache_store,
        key: "course_wizard_#{params[:provider_code]}_#{params[:recruitment_cycle_year]}_#{state_key}",
        expires_in: CACHE_EXPIRY,
      )
    end

    def wizard_cache_store
      Rails.env.development? ? LOCAL_CACHE_STORE : Rails.cache
    end
  end
end
