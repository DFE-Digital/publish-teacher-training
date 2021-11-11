module Support
  class AllocationsController < ApplicationController
    before_action :set_allocation, only: %i[show edit]
    def index
      @providers_with_allocations = filtered_providers_with_allocations.page(params[:page] || 1)
    end

    def show; end

    def edit; end

    def update
      if allocation.update(update_params)
        redirect_to support_allocation_path(allocation), flash: { success: "Allocation was successfully updated" }
      else
        render :edit
      end
    end

  private

    def allocation
      @allocation ||= Allocation.find(params[:id])
    end

    def filtered_providers_with_allocations
      Support::Providers::Filter.call(providers: Provider.with_allocations_for_current_cycle_year, filters: filters)
    end

    def filters
      @filters ||= ProviderFilter.new(params: filter_params).filters
    end

    def filter_params
      params.permit(:text_search, :page, :commit)
    end

    def update_params
      params.require(:allocation).permit(:confirmed_number_of_places)
    end

    def set_allocation
      allocation
    end
  end
end
