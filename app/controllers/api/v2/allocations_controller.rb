module API
  module V2
    class AllocationsController < API::V2::ApplicationController
      deserializable_resource :allocation,
                              class: API::V2::DeserializableAllocation

      def index
        authorize Allocation

        scope = Allocation.where(accredited_body_id: accredited_body.id)

        if params[:filter] && params[:filter][:training_provider_code]
          scope = scope.where(provider_code: params[:filter][:training_provider_code])
        end

        render jsonapi: policy_scope(scope),
               include: params[:include],
               status: :ok
      end

      def show
        authorize @allocation = Allocation.find(params[:id])

        render jsonapi: @allocation, include: params[:include], status: :ok
      end

      def create
        service = Allocations::Create.new(allocation_params.merge(accredited_body_id: accredited_body.id, request_type: get_request_type(allocation_params)))

        authorize service.object

        if service.execute
          render jsonapi: service.object, status: :created
        else
          render jsonapi_errors: service.object.errors, status: :unprocessable_entity
        end
      end

      def update
        authorize @allocation = Allocation.find(params[:id])

        service = Allocations::Update.new(@allocation, allocation_params)

        if service.execute
          render jsonapi: @allocation, status: :ok
        else
          render jsonapi_errors: @allocation.errors, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @allocation = Allocation.find(params[:id])

        if @allocation.safe_delete(current_recruitment_cycle)
          head :ok
        else
          render jsonapi_errors: @allocation.errors, status: :unprocessable_entity
        end
      end

    private

      def current_recruitment_cycle
        @current_recruitment_cycle ||= RecruitmentCycle.current_recruitment_cycle
      end

      def accredited_body
        @accredited_body ||= begin
                               accredited_body_code = params[:provider_code]
                               current_recruitment_cycle.providers.find_by!(provider_code: accredited_body_code)
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
            :request_type,
          )
      end

      # TODO remove when publish is doing the right thing
      def get_request_type(permitted_params)
        return permitted_params[:request_type] if permitted_params[:request_type].present?

        case permitted_params[:number_of_places]
        when "0"
          "declined"
        when nil
          "repeat"
        else
          "initial"
        end
      end
    end
  end
end
