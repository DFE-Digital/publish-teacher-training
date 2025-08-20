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
    counts = {}

    elapsed = Benchmark.measure do
      counts = within_transaction { copy_provider }
    end

    counts.merge(duration_seconds: elapsed)
  end

private

  attr_reader :provider_code, :course_codes, :force

  def within_transaction(&block)
    Provider.connection.transaction(&block)
  end

  def copy_provider
    copy_provider_to_recruitment_cycle.execute(
      provider:,
      new_recruitment_cycle:,
      course_codes:,
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

  def copy_provider_to_recruitment_cycle
    @copy_provider_to_recruitment_cycle ||= Providers::CopyToRecruitmentCycleService.new(
      copy_course_to_provider_service: copy_courses_to_provider_service,
      copy_site_to_provider_service: Sites::CopyToProviderService.new,
      copy_partnership_to_provider_service: Partnerships::CopyToProviderService.new,
      force:,
    )
  end

  def copy_courses_to_provider_service
    @copy_courses_to_provider_service ||= Courses::CopyToProviderService.new(
      sites_copy_to_course: Sites::CopyToCourseService,
      enrichments_copy_to_course: Enrichments::CopyToCourseService.new,
      force:,
    )
  end
end
