# frozen_string_literal: true

require 'rails_helper'

RSpec.describe APICourseSearchService do
  describe '.call' do
    subject(:result) { described_class.call(filter:, sort:, course_scope: Course.all) }

    let(:filter) { {} }
    let(:sort) { nil }

    context 'when filtering by course type' do
      it 'returns all course types' do
        undergraduate_course = create(:course, :published_teacher_degree_apprenticeship)
        postgraduate_course = create(:course, :published_postgraduate)

        expect(result).to contain_exactly(undergraduate_course, postgraduate_course)
      end
    end

    context 'when ordering courses by creation date' do
      it 'orders courses by created at ascending' do
        course_three = create(:course, created_at: 4.days.ago)
        course_one = create(:course, created_at: 10.days.ago)
        course_four = create(:course, created_at: 1.day.ago)
        course_two = create(:course, created_at: 9.days.ago)

        expect(result.pluck(:id)).to eq(
          [course_one.id, course_two.id, course_three.id, course_four.id]
        )
      end
    end
  end
end
