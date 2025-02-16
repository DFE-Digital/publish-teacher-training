# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Find::Analytics::SearchResultsEvent do
  subject do
    described_class.new(attributes.merge(request:))
  end

  let(:request) { ActionDispatch::Request.new({}) }

  let(:attributes) { {} }

  it_behaves_like 'an analytics event'

  describe '#event_name' do
    it 'returns :search_results' do
      expect(subject.event_name).to eq(:search_results)
    end
  end

  describe '#event_data' do
    let(:attributes) do
      {
        total: 1360,
        page: 2,
        search_params: {
          send_courses: true,
          can_sponsor_visa: true
        },
        track_params: {
          utm_source: 'homepage',
          utm_medium: 'search-form'
        },
        results: [
          create(:course, course_code: 'abc', provider: build(:provider, provider_code: 'rst')),
          create(:course, course_code: 'def', provider: build(:provider, provider_code: 'uvw'))
        ]
      }
    end

    it 'returns a hash with all the results information' do
      expect(subject.event_data).to eq(
        total: 1360,
        page: 2,
        visible_courses: [
          { code: 'abc', provider_code: 'rst' },
          { code: 'def', provider_code: 'uvw' }
        ],
        search_params: {
          send_courses: true,
          can_sponsor_visa: true
        },
        track_params: {
          utm_source: 'homepage',
          utm_medium: 'search-form'
        }
      )
    end
  end
end
