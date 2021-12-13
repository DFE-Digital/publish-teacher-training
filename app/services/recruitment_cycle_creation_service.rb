class RecruitmentCycleCreationService
  include ServicePattern

  def initialize(year:, application_start_date:, application_end_date:, summary: false)
    @year = year
    @application_start_date = application_start_date
    @application_end_date = application_end_date
    @summary = summary
  end

  def call
    RecruitmentCycle.create!(year: @year, application_start_date: @application_start_date, application_end_date: @application_end_date)

    if @summary
      Rails.logger.info { "The new RecruitmentCycle has been successfully created for:\n\nyear: '#{@year}'\napplication_start_date: '#{@application_start_date}'\napplication_end_date: '#{@application_end_date}'\n\n" }
    end
  end
end
