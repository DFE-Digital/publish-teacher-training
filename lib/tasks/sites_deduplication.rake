# frozen_string_literal: true

namespace :sites do
  namespace :deduplicate do
    desc "Dry run the site deduplication process for school sites"
    task :dry_run, [:provider_id] => :environment do |_task, args|
      Sites::Deduplication::TaskRunner.new(dry_run: true, args:).call
    end

    desc "Execute the site deduplication process for school sites"
    task :run, [:provider_id] => :environment do |_task, args|
      Sites::Deduplication::TaskRunner.new(dry_run: false, args:).call
    end
  end
end
