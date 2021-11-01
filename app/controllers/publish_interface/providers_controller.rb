module PublishInterface
  class ProvidersController < ApplicationController
    before_action :build_recruitment_cycle
    before_action :build_provider, except: %i[index show]

    def index
      authorize Provider

      page = (params[:page] || 1).to_i
      per_page = 10

      @providers = policy_scope(@recruitment_cycle.providers)
        .include_courses_counts
        .includes(:recruitment_cycle)
        .by_name_ascending
      @providers = @providers.where(id: current_user.providers)
      @providers = @providers.page(page).per(per_page)
    end

    def show
      @provider = Provider
        .where(recruitment_cycle: @recruitment_cycle)
        .where(provider_code: params[:provider_code])
        .first

      authorize @provider, :show?
    end

    def details
      # redirect_to_contact_page_with_ukprn_error if @provider.ukprn.blank?

      @errors = flash[:error_summary]
      flash.delete(:error_summary)
    end

    def contact
      show_deep_linked_errors(%i[email telephone website address1 address3 address4 postcode])
    end

  private

    def build_recruitment_cycle
      cycle_year = params[:recruitment_cycle_year] || params[:year] || Settings.current_cycle
      @recruitment_cycle = RecruitmentCycle.find_by(year: cycle_year)
    end

    def build_provider
      @provider = Provider
        .where(recruitment_cycle: @recruitment_cycle)
        .where(params[:provider_code])
        .first
    end

    def show_deep_linked_errors(attributes)
      return if params[:display_errors].blank?

      @provider.publishable?
      @errors = @provider.errors.messages.select { |key| attributes.include? key }
    end

    def redirect_to_contact_page_with_ukprn_error
      flash[:error] = { id: "provider-error", message: "Please enter a UKPRN before continuing" }

      redirect_to contact_publish_interface_provider_recruitment_cycle_path(@provider.provider_code, @provider.recruitment_cycle.year)
    end
  end
end
