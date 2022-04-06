module Publish
  module Providers
    class AllocationsController < PublishController
      def index
        authorize(Allocation)

        @allocations_view = AllocationsView.new(
          allocations: allocations[Settings.allocation_cycle_year.to_s] || [], training_providers: training_providers,
        )
      end

    private

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
        @training_providers ||= (allocations[previous_recruitment_cycle.year.to_i] || []).filter_map { |a|
          a.provider if a.request_type != AllocationsView::RequestType::DECLINED
        }.sort_by(&:provider_name)
      end
    end
  end
end
