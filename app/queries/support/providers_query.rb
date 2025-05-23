module Support
  class ProvidersQuery < ApplicationQuery
    attr_reader :params

    def initialize(params:)
      super()

      @params = params
    end

    def call
      scope = RecruitmentCycle.current.providers.includes(:recruitment_cycle)
      scope = search_filter(scope)
      scope = accredited_filter(scope)

      scope.order(provider_name: :asc)
    end

  private

    def search_filter(scope)
      return scope if params[:search].blank?

      scope.where(<<~SQL.squish, search: "%#{params[:search]}%")
        provider_name ILIKE :search OR
        ukprn LIKE :search
      SQL
    end

    def accredited_filter(scope)
      return scope if Array.wrap(params[:accredited]).blank?

      scope.where(accredited: Array.wrap(params[:accredited]))
    end
  end
end
