# frozen_string_literal: true

require 'rails_helper'

module Find
  describe Results::SearchResultComponent, type: :component do
    let(:args) do
      search_params = { 'age_group' => 'primary',
                        'applications_open' => 'true',
                        'c' => 'England',
                        'degree_required' => 'show_all_courses',
                        'l' => '1',
                        'latitude' => '51.5072178',
                        'loc' => 'London, UK',
                        'longitude' => '-0.1275862',
                        'lq' => 'London',
                        'page' => '1',
                        'can_sponsor_visa' => 'false',
                        'filtered_by_location' => 'true',
                        'radius' => '1',
                        'sortby' => 'distance',
                        'has_vacancies' => 'true',
                        'subjects[]' => 'G1j',
                        'subjects' => ['00'],
                        'visa_status' => 'false' }
      { filtered_by_location: true,
        results_view: ResultsView.new(query_parameters: MatchOldParams.call(search_params)),
        course: }
    end

    describe 'location row' do
      context 'fee based course with no sites' do
        let(:course) do
          build(
            :course,
            :fee_type_based,
            sites: [],
            funding: 'fee'
          )
        end

        it 'renders Not listed' do
          result = render_inline(described_class.new(**args))

          expect(result.text).to include(
            'Not listed yet'
          )
        end
      end

      context 'fee based course with 2 sites' do
        let(:course) do
          build(
            :course,
            :fee_type_based,
            :with_2_full_time_sites,
            funding: 'fee'
          )
        end

        it 'renders 2 placement locations' do
          result = render_inline(described_class.new(**args))

          expect(result.text).to include(
            'Placement school',
            '9 miles from London',
            'Nearest of 2 potential placement schools'
          )
        end
      end

      context 'fee based course with 1 site' do
        let(:course) do
          build(
            :course,
            :fee_type_based,
            :with_full_time_sites,
            funding: 'fee'
          )
        end

        it 'renders one placement location' do
          result = render_inline(described_class.new(**args))

          expect(result.text).to include(
            'Placement school',
            '9 miles from London',
            'Nearest potential placement school'
          )
        end
      end

      context 'salary based course with no sites' do
        let(:course) do
          build(
            :course,
            :salary_type_based,
            sites: [],
            funding: 'salary'
          )
        end

        it 'renders correct message' do
          result = render_inline(described_class.new(**args))

          expect(result.text).to include(
            'Not listed yet'
          )
        end
      end

      context 'salary based course with 2 sites' do
        let(:course) do
          build(
            :course,
            :salary_type_based,
            :with_2_full_time_sites,
            funding: 'salary'
          )
        end

        it 'renders correct message' do
          result = render_inline(described_class.new(**args))

          expect(result.text).to include(
            'Employing school',
            '9 miles from London',
            'Nearest of 2 potential employing school'
          )
        end
      end

      context 'salary based course with 1 site' do
        let(:course) do
          build(
            :course,
            :salary_type_based,
            :with_full_time_sites,
            funding: 'salary'
          )
        end

        it 'renders one employing location' do
          result = render_inline(described_class.new(**args))

          expect(result.text).to include(
            'Employing school',
            '9 miles from London',
            'Nearest potential employing schoo'
          )
        end
      end
    end
  end
end
