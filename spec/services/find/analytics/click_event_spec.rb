# frozen_string_literal: true

require "rails_helper"

RSpec.describe Find::Analytics::ClickEvent do
  subject do
    described_class.new(
      utm_content: "example_utm",
      url: "http://example.com",
      request:,
    )
  end

  let(:request) { ActionDispatch::Request.new({}) }

  it_behaves_like "an analytics event"

  describe "#event_name" do
    it "returns :track_click" do
      expect(subject.event_name).to eq(:track_click)
    end
  end

  describe "#event_data" do
    it "returns a hash with utm_content and url" do
      expect(subject.event_data).to eq({ utm_content: "example_utm", url: "http://example.com" })
    end
  end
end
