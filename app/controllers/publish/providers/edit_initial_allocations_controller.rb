module Publish
  module Providers
    class EditInitialAllocationsController < PublishController
      def edit
        authorize allocation

        flow = EditInitialRequestFlow.new(params: params)

        if request.post? && flow.valid?
          redirect_to flow.redirect_path
        else
          render flow.template, locals: flow.locals
        end
      end

      def update
        authorize allocation

        update_allocation

        redirect_to publish_provider_recruitment_cycle_allocation_path(
          provider_code: allocation.accredited_body.provider_code,
          recruitment_cycle_year: recruitment_cycle.year,
          training_provider_code: allocation.provider.provider_code,
          id: allocation.id,
        )
      end

      def delete
        authorize allocation

        allocation.destroy

        redirect_to publish_provider_recruitment_cycle_allocation_confirm_deletion_path(
          provider_code: provider.provider_code,
          recruitment_cycle_year: recruitment_cycle.year,
          training_provider_code: training_provider.provider_code,
        )
      end

      def confirm_deletion
        authorize provider, :show?
        @allocation = Allocation.new(request_type: AllocationsView::RequestType::DECLINED)

        training_provider
        provider
        recruitment_cycle
        render template: "publish/providers/allocations/show"
      end

    private

      def allocation
        @allocation ||= Allocation.includes(:provider, :accredited_body)
                                  .find(params[:id])
      end

      def update_allocation
        allocation.number_of_places = params[:number_of_places].to_i
        allocation.save
      end

      def training_provider
        @training_provider ||= recruitment_cycle.providers.find_by(provider_code: params[:allocation_training_provider_code])
      end
    end
  end
end
