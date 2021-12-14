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
      Support::Filter.call(model_data_scope: Allocation.current_allocations, filter_model: filter)
    end

    def filter
      @filter ||= Support::Allocations::Filter.new(params: filter_params)
    end

    def filters
      @filters ||= filter.filters
    end

    def filter_params
      params.permit(:text_search, :page, :commit)
    end
  end
end
