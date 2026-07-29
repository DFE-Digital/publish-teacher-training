# frozen_string_literal: true

namespace :schools_remodel_preflight do
  desc "Report the data gaps that block moving the course school pickers onto Provider::School"
  task :run, %i[recruitment_cycle_year] => :environment do |_task, args|
    year = args[:recruitment_cycle_year] || RecruitmentCycle.current_recruitment_cycle.year

    report = DataHub::SchoolsRemodelPreflight::Report.new(recruitment_cycle_year: year).call

    puts "Schools remodel pre-flight — recruitment cycle #{year}"
    pp report.counts

    if report.blocking?
      puts "\nBLOCKING — orphan provider_schools would resurrect removed schools in the picker:"
      report.orphan_provider_schools.each { |row| pp row }
    end

    puts "\nKept sites with no provider_school (would vanish from the picker):"
    report.unmapped_sites.each { |row| pp row }

    puts "\nLive attachments with no course_school row (rely on the picker's union rule):"
    report.unmapped_attachments.each { |row| pp row }

    report.empty_pickers.each do |level, rows|
      next if rows.empty?

      puts "\nProviders who would see no selectable schools on a #{level.humanize.downcase} course:"
      rows.each { |row| pp row }
    end

    abort("\nPre-flight failed: fix the orphan provider_schools before migrating the pickers.") if report.blocking?
  end
end
