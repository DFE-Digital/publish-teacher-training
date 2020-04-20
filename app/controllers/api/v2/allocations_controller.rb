module API
  module V2
    class AllocationsController < API::V2::ApplicationController
      deserializable_resource :allocation,
                              class: API::V2::DeserializableAllocation
      def index
        authorize Allocation

        render jsonapi: policy_scope(Allocation.where(accredited_body_id: accredited_body.id)), status: :ok
      end

      def create
        authorize @allocation = Allocation.new(allocation_params.merge(accredited_body_id: accredited_body.id))

        # hardcoded till back filling of data is implemented
        @allocation.number_of_places ||= 42

        if @allocation.save
          render jsonapi: @allocation, status: :created
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
          )
      end
    end
  end
end
