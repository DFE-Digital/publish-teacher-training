module Support
  class AllocationsController < SupportController
    def index
      @allocations = filtered_allocations
    end

    def show
      allocation
    end

  private

    def allocation
      @allocation ||= Allocation.find(params[:id])
    end

    def filtered_allocations
      @filtered_allocations ||= Support::Filter.call(model_data_scope: Allocation.current_allocations, filter_params:)
    end

    def filter_params
      @filter_params ||= params.except(:commit, :recruitment_cycle_year).permit(:text_search, :page)
    end
  end
end
