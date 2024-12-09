# frozen_string_literal: true

class CoursesQuery
  def self.call(...)
    new(...).call
  end

  attr_reader :scope, :params

  def initialize(params:)
    @params = params
    @applied_scopes = {}
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
    @scope = visa_sponsorship_scope
    @scope = @scope.distinct

    log_query_info

    @scope
  end

  def visa_sponsorship_scope
    return @scope if params[:can_sponsor_visa].blank?

    @applied_scopes[:can_sponsor_visa] = params[:can_sponsor_visa]

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

  def log_query_info
    CoursesQuery::Logger.new(@applied_scopes, @scope).call
  end
end
