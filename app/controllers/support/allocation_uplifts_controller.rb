module Support
  class AllocationUpliftsController < ApplicationController
    def edit
      allocation_uplift
    end

    def update
      if allocation_uplift.update(update_allocation_uplift_params)
        redirect_to support_allocation_path(allocation_uplift.allocation)
      else
        render :edit
      end
    end

    def new
      @allocation_uplift = AllocationUplift.new(allocation: allocation)
    end

    def create
      @allocation = Allocation.find(create_allocation_uplift_params[:allocation_id].to_i)
      @allocation_uplift = AllocationUplift.new(allocation: @allocation, uplifts: create_allocation_uplift_params[:uplifts])
      if @allocation_uplift.save
        redirect_to support_allocation_path(allocation), flash: { success: "Allocation Uplift was successfully created" }
      else
        render :new
      end
    end

  private

    def allocation_uplift
      @allocation_uplift ||= AllocationUplift.find(params[:id])
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
