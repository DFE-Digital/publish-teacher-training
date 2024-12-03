# frozen_string_literal: true

class CoursesQuery
  def self.call(params = {})
    new(params:).call
  end

  attr_reader :scope

  def initialize(params:)
    @params = params
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
    @scope.distinct
  end
end
