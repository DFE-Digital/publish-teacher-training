require "rails_helper"

RSpec.describe V3::CourseSearchService do
  describe ".call" do
    before do
      allow(::CourseSearchService).to receive(:call)
    end

    subject do
      described_class.call
    end

    it "call ::CourseSearchService" do
      subject
      expect(::CourseSearchService).to have_received(:call)
    end
  end
end
