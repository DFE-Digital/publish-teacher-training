# frozen_string_literal: true

require 'rails_helper'

module Find
  describe Results::NoResultsComponent, type: :component do
    let(:no_results_extra_message) do
      'There are not many teacher degree apprenticeship (TDA) courses on the service at the moment. You can try again soon when there may be more courses, or get in touch with us at becomingateacher@digital.education.gov.uk.'
    end

    it 'renders nothing if there are results' do
      results_view = instance_double(
        Find::ResultsView,
        country: 'Scotland',
        devolved_nation?: true,
        no_results_found?: false,
        show_undergraduate_courses?: false
      )
      component = render_inline(described_class.new(results: results_view))

      expect(component.text).to be_blank
    end

    context 'Devolved nations' do
      it 'renders devolved nation warning' do
        results_view = instance_double(
          Find::ResultsView,
          country: 'Scotland',
          devolved_nation?: true,
          no_results_found?: true,
          show_undergraduate_courses?: false
        )
        component = render_inline(described_class.new(results: results_view))

        expect(component.text).to include('This service is for courses in England')
      end

      context 'Scotland' do
        it 'renders Scottish teacher training website' do
          results_view = instance_double(
            Find::ResultsView,
            country: 'Scotland',
            devolved_nation?: true,
            no_results_found?: true,
            show_undergraduate_courses?: false
          )
          component = render_inline(described_class.new(results: results_view))

          expect(component).to have_link('Learn more about teacher training in Scotland', href: 'https://teachinscotland.scot/')
        end
      end

      context 'Wales' do
        it 'renders Welsh teacher training website' do
          results_view = instance_double(
            Find::ResultsView,
            country: 'Wales',
            devolved_nation?: true,
            no_results_found?: true,
            show_undergraduate_courses?: false
          )
          component = render_inline(described_class.new(results: results_view))

          expect(component).to have_link('Learn more about teacher training in Wales', href: 'https://educators.wales/teachers')
        end
      end

      context 'Northern Ireland' do
        it 'renders Northern Ireland training website' do
          results_view = instance_double(
            Find::ResultsView,
            country: 'Northern Ireland',
            devolved_nation?: true,
            no_results_found?: true,
            show_undergraduate_courses?: false
          )
          component = render_inline(described_class.new(results: results_view))

          expect(component).to have_link('Learn more about teacher training in Northern Ireland', href: 'https://www.education-ni.gov.uk/articles/initial-teacher-education-courses-northern-ireland')
        end
      end
    end

    context 'when no results for undergraduate' do
      it 'does show extra message' do
        results_view = Find::ResultsView.new(
          query_parameters: ActionController::Parameters.new(
            'age_group' => 'secondary',
            'can_sponsor_visa' => 'false',
            'has_vacancies' => 'true',
            'university_degree_status' => 'false',
            'visa_status' => 'false'
          )
        )
        component = render_inline(described_class.new(results: results_view))
        expect(component.text).to include(no_results_extra_message)
      end
    end

    context 'when no results for postgraduate' do
      it 'does not show extra message' do
        results_view = Find::ResultsView.new(
          query_parameters: ActionController::Parameters.new(
            'age_group' => 'secondary',
            'can_sponsor_visa' => 'false',
            'has_vacancies' => 'true',
            'university_degree_status' => 'true',
            'visa_status' => 'false'
          )
        )
        component = render_inline(described_class.new(results: results_view))
        expect(component.text).not_to include(no_results_extra_message)
      end
    end

    context 'England' do
      context 'a search with multiple subjects and both salaried and unsalaried courses' do
        it 'renders try another search text' do
          results_view = instance_double(
            Find::ResultsView,
            country: 'England',
            devolved_nation?: false,
            subjects: %w[Math English],
            with_salaries?: false,
            no_results_found?: true,
            show_undergraduate_courses?: false
          )
          component = render_inline(described_class.new(results: results_view))

          expect(component.text).to include('You can try another search, for example by changing subjects or location')
          expect(component.text).not_to include('or searching for courses that do not offer a salary')
          expect(component.text).not_to include('This service is for courses in England')
        end
      end

      context 'a search with a single subject and both salaried and unsalaried courses' do
        it 'renders try another search text' do
          results_view = instance_double(
            Find::ResultsView,
            country: 'England',
            devolved_nation?: false,
            subjects: %w[Math],
            with_salaries?: false,
            no_results_found?: true,
            show_undergraduate_courses?: false
          )
          component = render_inline(described_class.new(results: results_view))

          expect(component.text).to include('You can try another search, for example by changing subject or location')
          expect(component.text).not_to include('or searching for courses that do not offer a salary')
        end
      end

      context 'a search with multiple subject and salaried courses only' do
        it 'renders try another search text' do
          results_view = instance_double(
            Find::ResultsView,
            country: 'England',
            devolved_nation?: false,
            subjects: %w[Math],
            with_salaries?: true,
            no_results_found?: true,
            show_undergraduate_courses?: false
          )
          component = render_inline(described_class.new(results: results_view))

          expect(component.text).to include('You can try another search, for example by changing subject or location or searching for courses that do not offer a salary')
          expect(component.text).to include('or searching for courses that do not offer a salary')
        end
      end
    end
  end
end
