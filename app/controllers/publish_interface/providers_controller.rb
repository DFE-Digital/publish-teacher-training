module PublishInterface
  class ProvidersController < ApplicationController
    before_action :build_recruitment_cycle

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

  private

    def build_recruitment_cycle
      cycle_year = params[:recruitment_cycle_year] || params[:year] || Settings.current_cycle
      @recruitment_cycle = RecruitmentCycle.find_by(year: cycle_year)
    end
  end
end
