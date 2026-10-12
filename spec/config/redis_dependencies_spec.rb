# frozen_string_literal: true

require "rails_helper"

# Redis is being retired. Background jobs run on Solid Queue and the cache on
# Solid Cache; the files below are the only remaining Redis or Sidekiq users,
# and each is due to be removed. A new call site would quietly keep Redis
# alive, so it must be added here on purpose.
RSpec.describe "Redis and Sidekiq dependencies" do
  known_call_sites = %w[
    app/controllers/heartbeat_controller.rb
    app/jobs/application_job.rb
    app/lib/feature_flag.rb
    app/lib/site_setting.rb
    app/services/stores/base_store.rb
    config/initializers/redis.rb
    config/initializers/sidekiq.rb
    config/routes/publish.rb
    lib/tasks/big_query.rake
  ]

  call_site = /\bRedis(Client)?(\.|::)|\bSidekiq(\.|::)|\bperform_async\b|\bperform_in\b|\bsidekiq_options\b|\binclude Sidekiq\b/

  it "only uses Redis or Sidekiq from the known call sites" do
    files = Dir.glob(Rails.root.join("{app,lib,config}/**/*.{rb,rake}"))

    call_sites = files.select do |file|
      File.foreach(file).any? { |line| !line.lstrip.start_with?("#") && line.match?(call_site) }
    end

    relative = call_sites.map { |file| Pathname(file).relative_path_from(Rails.root).to_s }

    expect(relative).to match_array(known_call_sites)
  end
end
