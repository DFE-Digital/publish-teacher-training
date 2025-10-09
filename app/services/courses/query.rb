# frozen_string_literal: true

module Courses
  class Query
    DEFAULT_RADIUS_IN_MILES = 10

    attr_reader :applied_scopes, :scope, :params

    def self.call(...)
      new(...).call
    end

    def initialize(params:)
      @params = params
      @applied_scopes = {}
      @current_recruitment_cycle = RecruitmentCycle.current

      @scope = Course
                 .joins(
                   <<~SQL,
                     INNER JOIN (
                       SELECT id, provider_name, provider_code, recruitment_cycle_id
                       FROM provider
                       WHERE recruitment_cycle_id = #{@current_recruitment_cycle.id}
                         AND discarded_at IS NULL
                     ) provider ON course.provider_id = provider.id
                     INNER JOIN course_site site_statuses ON (
                       site_statuses.course_id = course.id
                       AND site_statuses.status = 'R'
                       AND site_statuses.publish = 'Y'
                     )
                   SQL
                 )
                 .where(course: { discarded_at: nil })
                 .where(
                   provider: { recruitment_cycle_id: @current_recruitment_cycle.id },
                 )
                 .where(
                   site_statuses: {
                     status: SiteStatus.statuses[:running],
                     publish: SiteStatus.publishes[:published],
                   },
                 )
    end

    def call
      @scope = visa_sponsorship_scope
      @scope = engineers_teach_physics_scope
      @scope = subjects_scope
      @scope = study_modes_scope
      @scope = interview_location_scope
      @scope = qualifications_scope
      @scope = further_education_scope
      @scope = minimum_degree_required_scope
      @scope = applications_open_scope
      @scope = special_education_needs_scope
      @scope = funding_scope
      @scope = start_date_scope
      @scope = provider_scope
      @scope = optimisation_scope
      @scope = location_scope
      @scope = excluded_courses_scope

      if @applied_scopes[:location].blank?
        @scope = default_ordering_scope
        @scope = course_name_ascending_order_scope
        @scope = course_name_descending_order_scope
        @scope = provider_name_ascending_order_scope
        @scope = provider_name_descending_order_scope
      end

      log_query_info

      @scope
    end

    def optimisation_scope
      @scope.preload(
        :site_statuses,
        :latest_published_enrichment,
        :provider,
        subjects: [:financial_incentive],
      )
    end

    def count
      @scope.unscope(:order, :group).distinct.count(:id)
    end

    def visa_sponsorship_scope
      return @scope if params[:can_sponsor_visa].blank?

      @applied_scopes[:can_sponsor_visa] = params[:can_sponsor_visa]

      @scope
        .where(
          can_sponsor_student_visa: true,
        )
        .or(
          @scope.where(
            can_sponsor_skilled_worker_visa: true,
          ),
        )
    end

    def engineers_teach_physics_scope
      return @scope if params[:engineers_teach_physics].blank?

      @applied_scopes[:engineers_teach_physics] = params[:engineers_teach_physics]

      @scope.where(campaign_name: Course.campaign_names[:engineers_teach_physics])
    end

    def subjects_scope
      return @scope if params[:subjects].blank? && params[:subject_code].blank?

      subject_codes = [params[:subjects], params[:subject_code]].flatten.compact

      @applied_scopes[:subjects] = subject_codes

      @scope.joins(:subjects).where(subjects: { subject_code: subject_codes })
    end

    def excluded_courses_scope
      return @scope if params[:excluded_courses].blank?

      excluded_course_codes = Array.wrap(params[:excluded_courses]).compact_blank

      @applied_scopes[:excluded_courses] = excluded_course_codes

      new_scope = @scope

      excluded_course_codes
        .map { |excluded_course| ExcludedCourseParam.new(provider_code: excluded_course[:provider_code], course_code: excluded_course[:course_code]) }
        .each do |excluded_course_code|
        next unless excluded_course_code.valid?

        new_scope = new_scope.where
                             .not(
                               course_code: excluded_course_code.course_code,
                               provider: { provider_code: excluded_course_code.provider_code },
                             )
      end

      new_scope
    end

    def study_modes_scope
      return @scope if params[:study_types].blank?

      @applied_scopes[:study_modes] = params[:study_types]

      case params[:study_types]
      when %w[full_time]
        @scope.where(study_mode: [Course.study_modes[:full_time], Course.study_modes[:full_time_or_part_time]])
      when %w[part_time]
        @scope.where(study_mode: [Course.study_modes[:part_time], Course.study_modes[:full_time_or_part_time]])
      else
        @scope
      end
    end

    def qualifications_scope
      return @scope if params[:qualifications].blank?

      @applied_scopes[:qualifications_scope] = params[:qualifications]

      case params[:qualifications]
      when %w[qts]
        @scope.where(qualification: [Course.qualifications[:qts]])
      when %w[qts_with_pgce_or_pgde], %w[qts_with_pgce]
        @scope.where(qualification: [Course.qualifications[:pgce_with_qts], Course.qualifications[:pgde_with_qts]])
      else
        @scope
      end
    end

    def further_education_scope
      return @scope if params[:level] != "further_education"

      @applied_scopes[:level] = params[:level]

      @scope.where(level: Course.levels[:further_education])
    end

    def minimum_degree_required_scope
      return @scope if params[:minimum_degree_required].blank?

      minimum_degree_required = params[:minimum_degree_required]
      @applied_scopes[:minimum_degree_required] = minimum_degree_required

      case minimum_degree_required
      when "two_one"
        @scope.where(degree_grade: %w[two_one two_two third_class not_required], degree_type: :postgraduate)
      when "two_two"
        @scope.where(degree_grade: %w[two_two third_class not_required], degree_type: :postgraduate)
      when "third_class"
        @scope.where(degree_grade: %w[third_class not_required], degree_type: :postgraduate)
      when "pass"
        @scope.where(degree_grade: "not_required", degree_type: :postgraduate)
      when "no_degree_required"
        @scope.where(degree_grade: "not_required", degree_type: :undergraduate)
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

    def funding_scope
      return @scope if params[:funding].blank?

      @applied_scopes[:funding] = params[:funding]

      @scope.where(funding: params[:funding])
    end

    def interview_location_scope
      return @scope if params[:interview_location].blank?

      @applied_scopes[:interview_location] = params[:interview_location]

      @scope
        .joins(:latest_published_enrichment)
        .where("(course_enrichment.json_data->>'InterviewLocation') IN (?)", %w[online both])
    end

    def start_date_scope
      return @scope if params[:start_date].blank?

      @applied_scopes[:start_date] = params[:start_date]

      current_recruitment_cycle_year = Find::CycleTimetable.current_year
      september_range = Date.new(current_recruitment_cycle_year, 9, 1)..Date.new(current_recruitment_cycle_year, 9, 30)

      case params[:start_date]
      when %w[september]
        @scope = @scope.where(start_date: september_range)
      when %w[all_other_dates]
        @scope = @scope.where.not(start_date: september_range)
      else
        @scope
      end
    end

    def provider_scope
      return @scope if params[:provider_code].blank? && params[:provider_name].blank?

      @applied_scopes[:provider] = params[:provider_code] || params[:provider_name]

      providers = if params[:provider_code].present?
                    RecruitmentCycle.current.providers.where(provider_code: params[:provider_code])
                  else
                    RecruitmentCycle.current.providers.where(provider_name: params[:provider_name])
                  end

      @scope.where(
        provider_id: providers.select(:id),
      ).or(
        @scope.where(
          accredited_provider_code: providers.select(:provider_code),
        ),
      )
    end

    def location_scope
      return @scope.distinct if params[:latitude].blank? || params[:longitude].blank?

      radius_in_meters = radius_in_miles * 1609.34
      latitude = Float(params[:latitude])
      longitude = Float(params[:longitude])

      @applied_scopes[:location] = {
        latitude: latitude,
        longitude: longitude,
        radius: radius_in_miles,
      }

      @scope
        .joins("INNER JOIN site ON site.id = site_statuses.site_id")
        .where("(site.longitude IS NOT NULL OR site.latitude IS NOT NULL)")
        .where(
          <<~SQL.squish, longitude, latitude, radius_in_meters
            ST_DistanceSphere(
              ST_SetSRID(ST_MakePoint(site.longitude::float, site.latitude::float), 4326),
              ST_SetSRID(ST_MakePoint(?::float, ?::float), 4326)
            ) <= ?
          SQL
        )
        .select(
          Course.sanitize_sql_array(
            [
              <<~SQL.squish,
                course.*,
                MIN(ST_DistanceSphere(
                  ST_SetSRID(ST_MakePoint(site.longitude::float, site.latitude::float), 4326),
                  ST_SetSRID(ST_MakePoint(?::float, ?::float), 4326)
                ) / 1609.344) AS minimum_distance_to_search_location
              SQL
              longitude,
              latitude,
            ],
          ),
        )
        .group(:id)
        .order("minimum_distance_to_search_location ASC")
    end

    def default_ordering_scope
      return @scope if params[:order].present?

      params[:order] = "course_name_ascending"

      @scope
    end

    def course_name_ascending_order_scope
      return @scope unless params[:order] == "course_name_ascending"

      @applied_scopes[:order] = params[:order]

      @scope
        .select("course.*, provider.provider_name")
        .order(
          {
            courses_table[:name] => :asc,
            providers_table[:provider_name] => :asc,
            courses_table[:course_code] => :asc,
          },
        )
    end

    def course_name_descending_order_scope
      return @scope unless params[:order] == "course_name_descending"

      @applied_scopes[:order] = params[:order]

      @scope
        .select("course.*, provider.provider_name")
        .order(
          {
            courses_table[:name] => :desc,
            providers_table[:provider_name] => :asc,
            courses_table[:course_code] => :asc,
          },
        )
    end

    def provider_name_ascending_order_scope
      return @scope unless params[:order] == "provider_name_ascending"

      @applied_scopes[:order] = params[:order]

      @scope
        .select("course.*, provider.provider_name")
        .order(
          {
            providers_table[:provider_name] => :asc,
            courses_table[:name] => :asc,
            courses_table[:course_code] => :asc,
          },
        )
    end

    def provider_name_descending_order_scope
      return @scope unless params[:order] == "provider_name_descending"

      @applied_scopes[:order] = params[:order]

      @scope
        .select("course.*, provider.provider_name")
        .order(
          {
            providers_table[:provider_name] => :desc,
            courses_table[:name] => :asc,
            courses_table[:course_code] => :asc,
          },
        )
    end

    def radius_in_miles
      Float(params[:radius].presence || DEFAULT_RADIUS_IN_MILES)
    rescue StandardError
      DEFAULT_RADIUS_IN_MILES
    end

  private

    def log_query_info
      Courses::QueryLogger.new(self).call
    end

    def courses_table
      Course.arel_table
    end

    def providers_table
      Provider.arel_table
    end

    ExcludedCourseParam = Data.define(:provider_code, :course_code) do
      def valid?
        provider_code.present? && course_code.present?
      end
    end
  end
end
