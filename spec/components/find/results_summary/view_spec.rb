# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Find::ResultsSummary::View, type: :component do
  subject(:component) { described_class.new(courses_count:) }

  describe '#title' do
    context 'when courses_count is zero' do
      let(:courses_count) { 0 }

      it "returns 'No courses found'" do
        expect(component.title).to eq('No courses found')
      end
    end

    context 'when courses_count is one' do
      let(:courses_count) { 1 }

      it "returns '1 course found'" do
        expect(component.title).to eq('1 course found')
      end
    end

    context 'when courses_count is between 2 and 999' do
      let(:courses_count) { 123 }

      it 'returns the pluralized course count without delimiter' do
        expect(component.title).to eq('123 courses found')
      end
    end

    context 'when courses_count is 1,000 or greater' do
      let(:courses_count) { 1234 }

      it 'returns the pluralized and formatted course count with delimiter' do
        expect(component.title).to eq('1,234 courses found')
      end
    end
  end
end
