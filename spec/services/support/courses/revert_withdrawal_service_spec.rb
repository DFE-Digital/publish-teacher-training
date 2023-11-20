# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Support::Courses::RevertWithdrawalService do
  describe '#call' do
    let(:service) { described_class.new(course) }
    let(:course) { create(:course, :withdrawn, :open) }

    before do
      service.call
    end

    it 'publishes the latest enrichment' do
      expect(course.enrichments.max_by(&:created_at).status).to eq('published')
    end

    it 'sets the time stamp to the current time' do
      expect(course.enrichments.max_by(&:created_at).last_published_timestamp_utc).to be_within(1.minute).of(Time.now.utc)
    end

    it 'closes the course for applications' do
      expect(course.reload.application_status).to eq('closed')
    end

    it 'updates the course to published' do
      expect(course.reload.is_withdrawn?).to be_falsey
    end
  end
end
