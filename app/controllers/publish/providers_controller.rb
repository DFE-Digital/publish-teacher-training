module Publish
  class ProvidersController < PublishController
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    decorates_assigned :provider

    def index
      authorize :provider, :index?

      page = (params[:page] || 1).to_i
      per_page = 30
      @pagy, @providers = pagy(providers.order(:provider_name), page:, items: per_page)

      render "publish/providers/no_providers", status: :forbidden if @providers.blank?
      redirect_to publish_provider_path(@providers.first.provider_code) if @providers.count == 1

      session[:recruitment_cycle_year] = params[:recruitment_cycle_year]
    end

    def suggest
      authorize :provider, :show?

      @provider_list = providers
                        .provider_search(params[:query])
                        .limit(10)
                        .map { |provider| { code: provider.provider_code, name: provider.provider_name } }
      render json: @provider_list
    end

    def show
      authorize provider
      @recruitment_cycle_year = session[:recruitment_cycle_year]

      if FeatureService.enabled?(:new_publish_navigation) && !FeatureService.enabled?("rollover.can_edit_current_and_next_cycles")
        redirect_to publish_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year)
      elsif (@recruitment_cycle_year.to_i == Settings.current_recruitment_cycle_year) && (Settings.features.rollover.can_edit_current_and_next_cycles == true)
        redirect_to publish_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year)
        session.delete("recruitment_cycle_year")
      elsif (@recruitment_cycle_year.to_i == Settings.current_recruitment_cycle_year + 1) && (Settings.features.rollover.can_edit_current_and_next_cycles == true)
        redirect_to publish_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year.next)
        session.delete("recruitment_cycle_year")
      else
        :show?
      end
    end

    def details
      authorize provider, :show?

      redirect_to_contact_page_with_ukprn_error if provider.ukprn.blank?
      @errors = flash[:error_summary]
      flash.delete(:error_summary)
    end

    def about
      authorize provider, :show?

      @about_form = AboutYourOrganisationForm.new(provider)
    end

    def update
      authorize provider, :update?

      @about_form = AboutYourOrganisationForm.new(provider, params: provider_params)

      if @about_form.save!
        flash[:success] = I18n.t("success.published")
        redirect_to(
          details_publish_provider_recruitment_cycle_path(
            provider.provider_code,
            provider.recruitment_cycle_year,
          ),
        )
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

    def provider
      @provider ||= recruitment_cycle.providers.find_by!(provider_code: params[:provider_code] || params[:code])
    end

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
        .fetch(:publish_about_your_organisation_form, {})
        .permit(
          *AboutYourOrganisationForm::FIELDS,
          accredited_bodies: %i[provider_name provider_code description],
        )
    end
  end
end
