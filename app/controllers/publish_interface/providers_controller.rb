module PublishInterface
  class ProvidersController < PublishInterfaceController
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    before_action :build_recruitment_cycle
    before_action :build_provider, except: [:index]

    def index; end

    def details
      authorize @provider, :show?

      redirect_to_contact_page_with_ukprn_error if @provider.ukprn.blank?
      @errors = flash[:error_summary]
      flash.delete(:error_summary)
    end

    def about
      @about_form = PublishInterface::AboutYourOrganisationForm.build_from_provider(@provider)
    end

    def update
      authorize @provider, :update?

      @about_form = PublishInterface::AboutYourOrganisationForm.build_from_provider(@provider)
      @about_form.save(provider_params)

      if @about_form.valid?
        flash[:success] = I18n.t("success.published")
        redirect_to(
          details_publish_provider_recruitment_cycle_path(
            @provider.provider_code,
            @provider.recruitment_cycle_year,
          ),
        )
      else
        @errors = @about_form.errors.messages
        render provider_params["page"].to_sym
      end
    end

  private

    def build_recruitment_cycle
      cycle_year = params[:recruitment_cycle_year] || params[:year] || Settings.current_cycle
      @recruitment_cycle = RecruitmentCycle.find_by(year: cycle_year)
    end

    def build_provider
      @provider = Provider.find_by!(recruitment_cycle: @recruitment_cycle, provider_code: params[:provider_code])
    end

    def redirect_to_contact_page_with_ukprn_error
      flash[:error] = { id: "provider-error", message: "Please enter a UKPRN before continuing" }

      redirect_to contact_provider_recruitment_cycle_path(@provider.provider_code, @provider.recruitment_cycle_year)
    end

    def provider_params
      params
        .fetch(:publish_interface_about_your_organisation_form, {})
        .permit(:page, :train_with_us, :train_with_disability, accredited_bodies: [:provider_name, :provider_code, :description])
    end
  end
end
