# frozen_string_literal: true

module Find
  module Results
    class SearchResultComponentPreview < ViewComponent::Preview
      def by_location_with_2_sites
        course = FactoryBot.build_stubbed(:course)
        mock_results_view_class = Struct.new(:one) do
          def sites_count(*) = 2
          def query_parameters = { 'lq' => 'London' }
          def site_distance(*) = 2
        end
        results_view = mock_results_view_class.new(1)
        render(SearchResultComponent.new(
                 filtered_by_location: true,
                 results_view:,
                 course:
               ))
      end

      def by_location_with_1_site
        course = FactoryBot.build_stubbed(:course)
        mock_results_view_class = Struct.new(:one) do
          def sites_count(*) = 1
          def query_parameters = { 'lq' => 'London' }
          def site_distance(*) = 2.3
        end
        results_view = mock_results_view_class.new(1)
        render(SearchResultComponent.new(
                 filtered_by_location: true,
                 results_view:,
                 course:
               ))
      end

      def by_country_with_1_site
        course = FactoryBot.build_stubbed(:course)
        mock_results_view_class = Struct.new(:one) do
          def sites_count(*) = 1
          def query_parameters = {}
        end
        results_view = mock_results_view_class.new(1)
        render(SearchResultComponent.new(
                 filtered_by_location: false,
                 results_view:,
                 course:
               ))
      end

      def by_country_with_2_sites
        course = FactoryBot.build_stubbed(:course)
        mock_results_view_class = Struct.new(:one) do
          def sites_count(*) = 2
          def query_parameters = {}
        end
        results_view = mock_results_view_class.new(1)
        render(SearchResultComponent.new(
                 filtered_by_location: false,
                 results_view:,
                 course:
               ))
      end
    end
  end
end
