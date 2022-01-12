# frozen_string_literal: true

require "rails_helper"

describe PublishHelper do
  include PublishHelper

  describe "#old_publish_link_for" do
    let(:path) { "/publish/organisations/random" }
    let(:expected_path) { "#{Settings.publish_url}/organisations/random" }

    it "returns a correct url linking back to the old publish" do
      expect(old_publish_link_for(path)).to eq(expected_path)
    end
  end
end
