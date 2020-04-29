module API
  module V2
    class AllocationsController < API::V2::ApplicationController
      deserializable_resource :allocation,
                              class: API::V2::DeserializableAllocation

      def index
        authorize Allocation

        render jsonapi: policy_scope(Allocation.where(accredited_body_id: accredited_body.id)),
               include: params[:include],
               status: :ok
      end

      def show
        authorize @allocation = Allocation.find(params[:id])

        render jsonapi: @allocation, status: :ok
      end

      def create
        authorize @allocation = Allocation.new(allocation_params.merge(accredited_body_id: accredited_body.id))

        if @allocation.save
          render jsonapi: @allocation, status: :created
        else
          render jsonapi_errors: @allocation.errors, status: :unprocessable_entity
        end
      end

      def update
        authorize @allocation = Allocation.find(params[:id])

        if @allocation.update(allocation_update_params)
          render jsonapi: @allocation, status: :ok
        else
          render jsonapi_errors: @allocation.errors, status: :unprocessable_entity
        end
      end

    private

      def accredited_body
        @accredited_body ||= begin
                               accredited_body_code = params[:provider_code]
                               recruitment_cycle = RecruitmentCycle.current_recruitment_cycle
                               recruitment_cycle.providers.find_by!(provider_code: accredited_body_code)
                             end
      end

      def allocation_params
        params.require(:allocation)
          .permit(
            :provider_id,
            :number_of_places,
            :request_type,
          )
      end

      def allocation_update_params
        params.require(:allocation)
          .permit(
            :number_of_places,
          )
      end
    end
  end
end
