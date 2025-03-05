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

    context 'when there is a referer' do
      it 'returns a hash with all the results information' do
        allow(request).to receive(:referer).and_return('/')

        expect(subject.event_data).to eq(
          namespace: 'find',
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

    context 'when there is not a referer' do
      before do
        allow(request).to receive(:referer).and_return(nil)
      end

      it 'returns a hash with all the results information and no referer' do
        expect(subject.event_data).to eq(
          namespace: 'find',
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
            utm_source: 'results',
            utm_medium: 'no_referer'
          }
        )
      end
    end

    context 'when the referer is the course view page' do
      before do
        allow(request).to receive(:referer).and_return('/course/19S/2DTK')
      end

      it 'returns a hash with all the results information and course referer' do
        expect(subject.event_data).to eq(
          namespace: 'find',
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
            utm_source: 'course',
            utm_medium: 'course_view',
            code: '2DTK',
            provider_code: '19S'
          }
        )
      end
    end
  end
end
