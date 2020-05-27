class StatisticService
  def self.reporting(recruitment_cycle:)
    {
      providers: ProviderReportingService.call(providers_scope: recruitment_cycle.providers),
      courses: CourseReportingService.call(courses_scope: recruitment_cycle.courses),
      publish: PublishReportingService.call(recruitment_cycle_scope: recruitment_cycle),
    }
  end

  def self.save(recruitment_cycle: RecruitmentCycle.current_recruitment_cycle)
    Statistic.create!(json_data: reporting(recruitment_cycle: recruitment_cycle))
  end
end
