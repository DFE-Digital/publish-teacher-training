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

  let(:env) do
    { "HTTP_REFERER" => "https://find-teacher-blah.com/" }
  end
  let(:request) { ActionDispatch::Request.new(env) }

  it_behaves_like "an analytics event"

  describe "#event_name" do
    it "returns :track_click" do
      expect(subject.event_name).to eq(:track_click)
    end
  end

  describe "#event_data" do
    it "returns a hash with utm_content and url" do
      expect(subject.event_data).to eq({ data: { utm_content: "example_utm", url: "http://example.com" } })
    end
  end

  describe "#namespace" do
    let(:env) do
      { "HTTP_REFERER" => "https://find-teacher-training.com/publish" }
    end

    context "link clicked in Find" do
      it "returns 'find' for find referer" do
        expect(subject.namespace).to eq("find")
      end
    end

    context "link clicked in Publish" do
      let(:env) do
        { "HTTP_REFERER" => "https://publish-teacher-training.com/find" }
      end

      it "returns 'publish' for find referer" do
        expect(subject.namespace).to eq("publish")
      end
    end
  end
end
