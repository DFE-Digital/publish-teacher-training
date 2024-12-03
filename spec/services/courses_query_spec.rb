# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoursesQuery do
  let!(:findable_course) do
    create(:course, :with_full_time_sites)
  end
  let!(:another_course) do
    create(:course, :with_full_time_sites)
  end
  let!(:non_findable_course) do
    create(:course)
  end

  describe '.call' do
    context 'when no filters or sorting are applied' do
      it 'returns all findable courses' do
        result = described_class.call({})
        expect(result).to contain_exactly(findable_course, another_course)
      end
    end
  end
end
