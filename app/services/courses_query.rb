# frozen_string_literal: true

class CoursesQuery
  def self.call(params = {})
    new(params:).call
  end

  attr_reader :scope, :params

  def initialize(params:)
    @params = params
    @applied_filters = []
    @scope = RecruitmentCycle
             .current
             .courses
             .joins(:site_statuses)
             .where(
               site_statuses: {
                 status: SiteStatus.statuses[:running],
                 publish: SiteStatus.publishes[:published]
               }
             )
  end

  def call
    @scope = visa_sponsorship_filter
    @scope = @scope.distinct

    log_query_info

    @scope
  end

  def visa_sponsorship_filter
    return @scope if params[:can_sponsor_visa].blank?

    filter_applied(name: :can_sponsor_visa)

    @scope
      .where(
        can_sponsor_student_visa: true
      )
      .or(
        @scope.where(
          can_sponsor_skilled_worker_visa: true
        )
      )
  end

  private

  def filter_applied(name:)
    @applied_filters << { name:, value: params[name] }
  end

  def log_query_info
    CoursesQuery::Logger.new(@applied_filters, @scope).call
  end
end
