# frozen_string_literal: true

require "rails_helper"

# Redis and Sidekiq are retired from the app. Background jobs run on Solid Queue
# and the cache on Solid Cache. A new call site would quietly bring Redis back.
RSpec.describe "Redis and Sidekiq independence" do
  call_site = /\bRedis(Client)?(\.|::)|\bSidekiq(\.|::)|\bperform_async\b|\bperform_in\b|\bsidekiq_options\b|\binclude Sidekiq\b/

  it "has no Redis or Sidekiq runtime call sites in app, lib or config" do
    files = Dir.glob(Rails.root.join("{app,lib,config}/**/*.{rb,rake}"))

    call_sites = files.select do |file|
      File.foreach(file).any? { |line| !line.lstrip.start_with?("#") && line.match?(call_site) }
    end

    relative = call_sites.map { |file| Pathname(file).relative_path_from(Rails.root).to_s }

    expect(relative).to be_empty
  end
end
