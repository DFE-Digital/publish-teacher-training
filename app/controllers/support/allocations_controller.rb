module Support
  class AllocationsController < SupportController
    def index
      @allocations = filtered_allocations.page(params[:page] || 1)
    end

    def show
      allocation
    end

  private

    def allocation
      @allocation ||= Allocation.find(params[:id])
    end

    def filtered_allocations
      Support::Filter.call(model_data_scope: Allocation.current_allocations, filters: filters)
    end

    def filters
      @filters ||= ProviderFilter.new(params: filter_params).filters
    end

    def filter_params
      params.permit(:text_search, :page, :commit)
    end
  end
end
