# frozen_string_literal: true

class CoursesQuery
  def self.call(...)
    new(...).call
  end

  attr_reader :scope, :params, :applied_scopes

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
    @scope = study_modes_scope
    @scope = applications_open_scope
    @scope = special_education_needs_scope
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

  def study_modes_scope
    study_modes = Array(params[:study_types]).compact_blank

    return @scope if study_modes.blank?

    @applied_scopes[:study_modes] = study_modes

    case study_modes
    when ['full_time']
      @scope.where(study_mode: [Course.study_modes[:full_time], Course.study_modes[:full_time_or_part_time]])
    when ['part_time']
      @scope.where(study_mode: [Course.study_modes[:part_time], Course.study_modes[:full_time_or_part_time]])
    else
      @scope
    end
  end

  def applications_open_scope
    return @scope if params[:applications_open].blank?

    @applied_scopes[:applications_open] = params[:applications_open]

    @scope.where(application_status: Course.application_statuses[:open])
  end

  def special_education_needs_scope
    return @scope if params[:send_courses].blank?

    @applied_scopes[:send_courses] = params[:send_courses]

    @scope.where(is_send: true)
  end

  private

  def log_query_info
    CoursesQuery::Logger.new(self).call
  end
end
