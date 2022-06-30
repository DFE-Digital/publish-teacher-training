module Support
  class AllocationUpliftsController < SupportController
    def edit
      allocation_uplift
    end

    def new
      @allocation_uplift = AllocationUplift.new(allocation:)
    end

    def create
      @allocation_uplift = AllocationUplift.new(create_allocation_uplift_params)
      @allocation_uplift.allocation = allocation
      if @allocation_uplift.save
        redirect_to support_allocation_path(@allocation_uplift.allocation), flash: { success: "Allocation Uplift was successfully created" }
      else
        render :new
      end
    end

    def update
      if allocation_uplift.update(update_allocation_uplift_params)
        redirect_to support_allocation_path(allocation_uplift.allocation), flash: { success: "Allocation Uplift was successfully updated" }
      else
        render :edit
      end
    end

  private

    def allocation_uplift
      @allocation_uplift ||= allocation.allocation_uplift
    end

    def allocation
      @allocation ||= Allocation.find(params[:allocation_id])
    end

    def create_allocation_uplift_params
      params.require(:allocation_uplift).permit(:allocation_id, :uplifts)
    end

    def update_allocation_uplift_params
      params.require(:allocation_uplift).permit(:uplifts)
    end
  end
end
