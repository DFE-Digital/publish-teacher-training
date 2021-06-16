module API
  module V2
    class InterruptPageAcknowledgementsController < API::V2::ApplicationController
      before_action :build_user
      deserializable_resource :interrupt_page_acknowledgement, only: :create

      def index
       authorize @user

       interrupt_acknowledgements = @user.interrupt_page_acknowledgements
         .where(recruitment_cycle: recruitment_cycle)

        render jsonapi: paginate(interrupt_acknowledgements, per_page: 10),
               meta: { count: interrupt_acknowledgements.count },
               fields: { interrupt_acknowledgements: %i[type] }
      end

      def create
        authorize @user

        acknowledgement = InterruptPageAcknowledgement.find_or_initialize_by(
          user_id: params[:user_id],
          recruitment_cycle: recruitment_cycle,
          page: params.dig(:interrupt_page_acknowledgement, :page)
        )
        if acknowledgement.save
          render jsonapi: acknowledgement
        else
          render jsonapi_errors: acknowledgement.errors, status: :unprocessable_entity
        end
      end

    private

      def build_user
        @user = User.find(params[:user_id])
      end

      def recruitment_cycle
        RecruitmentCycle.find_by_year(params[:recruitment_cycle_year])
      end
    end
  end
end
