module Support
  class AllocationsController < ApplicationController
    def index
      @providers_with_allocations = filtered_providers_with_allocations.page(params[:page] || 1)
    end

    def show
      allocation
    end

  private

    def allocation
      @allocation ||= Allocation.find(params[:id])
    end

    def filtered_providers_with_allocations
      Support::Providers::Filter.call(providers: find_providers_with_allocations, filters: filters)
    end

    def find_providers_with_allocations
      Provider.where(id: Allocation.current_allocations.select(:provider_id)).order(:provider_name)
    end

    def filters
      @filters ||= ProviderFilter.new(params: filter_params).filters
    end

    def filter_params
      params.permit(:text_search, :page, :commit)
    end
  end
end
