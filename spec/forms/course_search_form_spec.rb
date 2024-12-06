# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CourseSearchForm do
  describe '#search_params' do
    context 'when can_sponsor_visa is true' do
      let(:form) { described_class.new(can_sponsor_visa: 'true') }

      it 'returns the correct search params with can_sponsor_visa set to true' do
        expect(form.search_params).to eq({ can_sponsor_visa: true })
      end
    end

    context 'when can_sponsor_visa is false' do
      let(:form) { described_class.new(can_sponsor_visa: 'false') }

      it 'returns the correct search params with can_sponsor_visa set to false' do
        expect(form.search_params).to eq({ can_sponsor_visa: false })
      end
    end

    context 'when no attributes' do
      let(:form) { described_class.new }

      it 'returns empty search params' do
        expect(form.search_params).to eq({})
      end
    end
  end
end
