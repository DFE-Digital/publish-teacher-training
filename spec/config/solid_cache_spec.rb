# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Solid Cache" do
  it "uses the primary database (no separate cache DB)" do
    # Pins the Apply-style wiring: cache.yml must not set `database: cache`.
    # That misconfig would expect an Azure database we do not provision.
    expect(SolidCache.configuration.connects_to).to be_nil
    expect(SolidCache::Entry.connection_db_config.name).to eq("primary")
  end
end
