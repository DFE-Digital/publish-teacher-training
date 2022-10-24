module Publish
  module Providers
    class AllocationsController < PublishController
      def index
        authorize provider, :show?

        @allocations_view = AllocationsView.new(
          allocations: allocations[Settings.allocation_cycle_year.to_s] || [], training_providers:,
        )
      end

      def new_repeat_request
        authorize provider, :show?
        provider
        training_provider
        @allocation = RepeatRequestForm.new
      end

      def show
        @allocation = Allocation.find(params[:id])
        provider
        training_provider

        authorize @allocation
      end

      def edit
        @allocation = Allocation.includes(:provider, :accredited_body)
        .find(params[:id])

        authorize @allocation

        training_provider
      end

      def create
        service = ::Allocations::Create.new(allocation_params.merge(accredited_body_id: provider.id, request_type: get_request_type(allocation_params)))

        authorize service.object

        @allocation = Publish::RepeatRequestForm.new(request_type: params[:request_type])

        if @allocation.valid? && service.execute
          redirect_to publish_provider_recruitment_cycle_allocation_path(id: service.object.id)
        else
          render :new_repeat_request
        end
      end

      def update
        @allocation = Allocation.find(params[:id])

        @allocation.request_type = params[:request_type]

        authorize @allocation

        @allocation.save if @allocation.changed?

        redirect_to publish_provider_recruitment_cycle_allocation_path(id: @allocation.id)
      end

      def initial_request
        authorize provider, :show?

        provider
        flow = InitialRequestFlow.new(params:)

        if request.post? && flow.valid? && flow.redirect?
          redirect_to flow.redirect_path
        else
          render flow.template, locals: flow.locals
        end
      end

    private

      def training_provider
        @training_provider ||= recruitment_cycle.providers.find_by(provider_code: params[:training_provider_code])
      end

      def allocation_params
        params.slice(
          :number_of_places,
          :request_type,
        ).merge(
          provider: recruitment_cycle.providers.find_by(provider_code: params[:training_provider_code]),
        ).to_unsafe_hash
      end

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

      def previous_recruitment_cycle
        @previous_recruitment_cycle ||= recruitment_cycle.previous
      end

      def allocations
        @allocations ||= Allocation
        .includes(:provider, :accredited_body, :allocation_uplift)
        .where(accredited_body_code: provider.provider_code, recruitment_cycle: [previous_recruitment_cycle, recruitment_cycle])
        .all
        .group_by { |a| a.provider.recruitment_cycle_year }
      end

      def training_providers
        @training_providers ||= (allocations[previous_recruitment_cycle.year.to_s] || []).filter_map { |a|
          a.provider if a.request_type != AllocationsView::RequestType::DECLINED
        }.sort_by(&:provider_name)
      end
    end
  end
end
