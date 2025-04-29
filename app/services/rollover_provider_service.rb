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
    Rails.logger.info { "Copying provider #{provider.provider_code}: " }
    counts = nil

    bm = Benchmark.measure do
      Provider.connection.transaction do
        counts = copy_provider_to_recruitment_cycle.execute(
          provider:, new_recruitment_cycle:, course_codes:,
        )
      end
    end

    Rails.logger.info "provider #{counts[:providers].zero? ? 'skipped' : 'copied'}, " \
                      "#{counts[:sites]} sites copied, " \
                      "#{counts[:courses]} courses copied " +
      sprintf("in %.3f seconds", bm.real)
    counts
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
      force:,
    )
  end
end
