# frozen_string_literal: true

require 'rails_helper'

module Find
  describe PlacementsController do
    before do
      Timecop.travel(Find::CycleTimetable.mid_cycle)
    end

    describe '#placements' do
      context 'when provider is not pressent' do
        it 'renders the not found page' do
          get :index, params: {
            provider_code: 'ABC',
            course_code: '123'
          }

          expect(response).to render_template('errors/not_found')
        end
      end

      context 'when course is not published' do
        it 'renders the not found page' do
          provider = create(:provider)
          course = create(:course, provider:)

          get :index, params: {
            provider_code: provider.provider_code,
            course_code: course.course_code
          }

          expect(response).to render_template('errors/not_found')
        end
      end
    end
  end
end
