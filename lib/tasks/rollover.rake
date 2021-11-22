namespace :rollover do
  desc "Rollover providers, courses and locations to the next cycle"
  task :providers, [:provider_codes] => :environment do |_task, args|
    provider_codes = args[:provider_codes]
    RolloverService.call(provider_codes: provider_codes&.split || [], force: nil)
  end

  desc "Create a new recruitment cycle"
  task :create_recruitment_cycle, %i[year application_start_date application_end_date] => :environment do |_task, args|
    RecruitmentCycleCreationService.call(year: args[:year], application_start_date: args[:application_start_date], application_end_date: args[:application_end_date], summary: true)
  end
end
