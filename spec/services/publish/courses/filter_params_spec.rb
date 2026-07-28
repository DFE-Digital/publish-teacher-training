# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Courses::FilterParams do
  describe ".permit" do
    def permit(hash)
      described_class.permit(ActionController::Parameters.new(hash))
    end

    it "permits every filter group as an array" do
      permitted = permit(status: %w[open], level: %w[primary], funding: %w[fee],
                         qualification: %w[qts], study_mode: %w[part_time], start_date: %w[2026-09])

      expect(permitted.to_h.symbolize_keys).to eq(
        status: %w[open], level: %w[primary], funding: %w[fee],
        qualification: %w[qts], study_mode: %w[part_time], start_date: %w[2026-09]
      )
    end

    it "drops params that are not filters" do
      expect(permit(status: %w[open], provider_code: "ABC").to_h.symbolize_keys).to eq(status: %w[open])
    end

    it "returns nothing when no filters are given" do
      expect(permit(provider_code: "ABC").to_h).to be_empty
    end
  end
end
