# frozen_string_literal: true

class RolloverProviderService
  include ServicePattern

  def initialize(provider_code:, force:, new_recruitment_cycle_id: nil, course_codes: nil)
    @provider_code = provider_code
    @course_codes = course_codes
    @new_recruitment_cycle_id = new_recruitment_cycle_id
    @force = force
  end

  def call
    rollover
  end

private

  attr_reader :provider_code, :course_codes, :force

  def rollover
    return handle_missing_provider unless provider

    summary = find_or_create_summary_record

    Rails.logger.info { "Copying provider #{provider.provider_code}: " }

    counts = nil
    bm = Benchmark.measure do
      Provider.connection.transaction do
        counts = copy_provider_to_recruitment_cycle.execute(
          provider:, new_recruitment_cycle:, course_codes:,
        )
      end
    rescue StandardError => e
      update_summary_failure(summary, e, bm&.real || 0)
      raise e
    end

    update_summary_success(summary, counts, bm.real)

    Rails.logger.info "provider #{counts[:providers].zero? ? 'skipped' : 'copied'}, " \
                      "#{counts[:sites]} sites copied, " \
                      "#{counts[:courses]} courses copied " +
      sprintf("in %.3f seconds", bm.real)

    counts
  end

  def handle_missing_provider
    Rails.logger.error "Provider with code #{provider_code} not found in current recruitment cycle"

    # Still create a summary record for tracking
    RolloverProviderSummary.create!(
      provider_id: nil,
      provider_code: provider_code,
      provider_name: nil,
      target_recruitment_cycle_id: new_recruitment_cycle.id,
      status: "failed",
      error_message: "Provider with code #{provider_code} not found in current recruitment cycle",
      summary_data: {},
      execution_time_seconds: 0,
    )

    { providers: 0, sites: 0, courses: 0 }
  end

  def find_or_create_summary_record
    RolloverProviderSummary.find_or_create_by(
      provider_code: provider_code,
      target_recruitment_cycle_id: new_recruitment_cycle.id,
    ) do |summary|
      summary.provider_id = provider&.id
      summary.provider_name = provider&.provider_name
      summary.status = "started"
      summary.summary_data = {}
    end
  end

  def update_summary_success(summary, counts, execution_time)
    status = counts[:providers].zero? ? "skipped" : "completed"

    summary.update!(
      status: status,
      summary_data: {
        providers: counts[:providers],
        sites: counts[:sites],
        courses: counts[:courses],
        study_sites: counts[:study_sites],
        force_rollover: force,
        course_codes_specified: course_codes.present?,
        course_codes_count: course_codes&.length || 0,
        counts: counts,
        timestamp: Time.current.iso8601,
      },
      execution_time_seconds: execution_time,
      error_message: nil,
    )
  end

  def update_summary_failure(summary, error, execution_time)
    summary.update!(
      status: "failed",
      error_message: "#{error.class}: #{error.message}",
      execution_time_seconds: execution_time,
      summary_data: summary.summary_data.merge(
        error_class: error.class.name,
        error_backtrace: error.backtrace&.first(10),
        timestamp: Time.current.iso8601,
      ),
    )
  end

  def new_recruitment_cycle
    @new_recruitment_cycle ||= if @new_recruitment_cycle_id.present?
                                 RecruitmentCycle.find(@new_recruitment_cycle_id)
                               else
                                 RecruitmentCycle.next_recruitment_cycle
                               end
  end

  def provider
    @provider ||= RecruitmentCycle.current_recruitment_cycle.providers.find_by(provider_code:)
  end

  def copy_courses_to_provider_service
    @copy_courses_to_provider_service ||= Courses::CopyToProviderService.new(
      sites_copy_to_course: Sites::CopyToCourseService,
      enrichments_copy_to_course: Enrichments::CopyToCourseService.new,
      force:,
    )
  end

  def copy_provider_to_recruitment_cycle
    @copy_provider_to_recruitment_cycle ||= Providers::CopyToRecruitmentCycleService.new(
      copy_course_to_provider_service: copy_courses_to_provider_service,
      copy_site_to_provider_service: Sites::CopyToProviderService.new,
      copy_partnership_to_provider_service: Partnerships::CopyToProviderService.new,
      force:,
    )
  end
end
