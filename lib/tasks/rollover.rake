namespace :rollover do
  desc "Rollover provider, courses and locations to the next cycle, (Use the force to rollover for non rollable provider and or courses)"
  task :provider, %i[provider_code course_codes force] => :environment do |_task, args|
    provider_code = args[:provider_code]
    course_codes = args[:course_codes]
    force = args[:force] == "true"

    RolloverProviderService.call(provider_code: provider_code, course_codes: course_codes&.split, force: force)
  end

  desc "Rollover providers, courses and locations to the next cycle"
  task :providers, [:provider_codes] => :environment do |_task, args|
    provider_codes = args[:provider_codes]
    RolloverService.call(provider_codes: provider_codes&.split || [])
  end

  desc "Create a new recruitment cycle"
  task :create_recruitment_cycle, %i[year application_start_date application_end_date] => :environment do |_task, args|
    RecruitmentCycleCreationService.call(year: args[:year], application_start_date: args[:application_start_date], application_end_date: args[:application_end_date], summary: true)
  end
end
