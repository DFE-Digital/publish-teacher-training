# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V3::CourseSearchService do
  describe '.call' do
    subject do
      described_class.call
    end

    before do
      allow(CourseSearchService).to receive(:call)
    end

    it 'call ::CourseSearchService' do
      subject
      expect(CourseSearchService).to have_received(:call)
    end
  end
end
