# frozen_string_literal: true

require 'rails_helper'

module Find
  describe LocationSubjectFilterComponent, type: :component do
    it 'renders the correct summary when location is used' do
      results = instance_double(Find::ResultsView, location_filter?: true, provider_filter?: false, filter_params_for: '/')

      allow(results).to receive_messages(filter_params_with_unescaped_commas: '/', location_search: 'Brighton', subjects: [{ subject_name: 'Art and design' }])

      page = render_inline(described_class.new(results:))

      expect(page.text).to include('Art and design')
      expect(page.text).to include('Brighton')
    end

    it 'renders the correct summary when england is used' do
      results = instance_double(Find::ResultsView, provider_filter?: false, england_filter?: true, location_filter?: false, filter_params_for: '/')

      allow(results).to receive_messages(filter_params_with_unescaped_commas: '/', subjects: [{ subject_name: 'Art and design' }])

      page = render_inline(described_class.new(results:))

      expect(page.text).to include('Art and design')
      expect(page.text).to include('England')
    end

    it 'renders the correct summary when provider is used' do
      results = instance_double(Find::ResultsView, provider_filter?: true, england_filter?: false, location_filter?: false, filter_params_for: '/')

      allow(results).to receive_messages(filter_params_with_unescaped_commas: '/', subjects: [{ subject_name: 'Art and design' }], provider: 'University of Brighton')

      page = render_inline(described_class.new(results:))

      expect(page.text).to include('Art and design')
      expect(page.text).to include('University of Brighton')
    end

    it 'renders two courses correctly' do
      results = instance_double(Find::ResultsView, location_filter?: true, provider_filter?: false, filter_params_for: '/')

      allow(results).to receive_messages(filter_params_with_unescaped_commas: '/', location_search: 'Brighton', subjects: [{ subject_name: 'Art and design' }, { subject_name: 'Maths' }])

      page = render_inline(described_class.new(results:))

      expect(page.text).to include('Art and design and Maths')
      expect(page.text).to include('Brighton')
    end

    it 'renders three courses correctly' do
      results = instance_double(Find::ResultsView, provider_filter?: false, location_filter?: true, filter_params_for: '/')

      allow(results).to receive_messages(filter_params_with_unescaped_commas: '/', location_search: 'Brighton', subjects: [{ subject_name: 'Art and design' }, { subject_name: 'Maths' }, { subject_name: 'English' }])

      page = render_inline(described_class.new(results:))

      expect(page.text).to include('Art and design, Maths and English')
      expect(page.text).to include('Brighton')
    end
  end
end
