# frozen_string_literal: true

require 'rails_helper'

module Find
  describe Results::SortByComponent, type: :component do
    it 'renders nothing when provider filter is active' do
      results_view = instance_double(
        Find::ResultsView,
        provider_filter?: true,
        no_results_found?: false
      )
      component = render_inline(described_class.new(results: results_view))

      expect(component.text).to eq('')
    end

    it 'renders nothing when no results were found' do
      results_view = instance_double(
        Find::ResultsView,
        provider_filter?: false,
        no_results_found?: true
      )
      component = render_inline(described_class.new(results: results_view))

      expect(component.text).to eq('')
    end

    it 'renders when provider filter is not active and search is by location' do
      results_view = instance_double(
        Find::ResultsView,
        location_filter?: true,
        provider_filter?: false,
        no_results_found?: false,
        location_search: 'London',
        filter_params_for: '/'
      )
      component = render_inline(described_class.new(results: results_view))

      expect(component.text).to include('Sorted by distance')
    end

    it 'renders when provider filter is not active and search is not by location' do
      results_view = instance_double(
        Find::ResultsView,
        location_filter?: false,
        provider_filter?: false,
        no_results_found?: false,
        sort_options: [
          ['Training provider (A-Z)', 0, { 'data-qa': 'sort-form__options__ascending' }],
          ['Training provider (Z-A)', 1, { 'data-qa': 'sort-form__options__descending' }]
        ]
      )
      component = render_inline(described_class.new(results: results_view))

      expect(component.text).to include('Sorted by')
      expect(component.text).to include('Training provider (A-Z)')
      expect(component.text).to include('Training provider (Z-A)')
    end
  end
end
