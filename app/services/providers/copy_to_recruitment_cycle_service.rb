# frozen_string_literal: true

module Providers
  class CopyToRecruitmentCycleService
    def initialize(copy_course_to_provider_service:, copy_schools_to_provider_service:, copy_site_to_provider_service:, copy_partnership_to_provider_service:, force:)
      @copy_course_to_provider_service = copy_course_to_provider_service
      @copy_schools_to_provider_service = copy_schools_to_provider_service
      @copy_site_to_provider_service = copy_site_to_provider_service
      @copy_partnership_to_provider_service = copy_partnership_to_provider_service
      @force = force
    end

    def execute(provider:, new_recruitment_cycle:, course_codes: nil)
      result = init_result_hash

      if provider_eligible?(provider)
        ActiveRecord::Base.transaction do
          # Each copied site, school, enrichment and site status would otherwise
          # touch its parent provider and course on every save. Suppress that and
          # stamp the parents once, below.
          TouchSuppression.suppress do
            rolled_over_provider = find_or_create_provider_in_cycle(provider, new_recruitment_cycle, result)

            copy_schools(provider, rolled_over_provider, result)
            copy_study_sites(provider, rolled_over_provider, result)
            copy_courses(provider, rolled_over_provider, course_codes, result)
            result[:partnerships] = copy_partnerships(provider, rolled_over_provider, new_recruitment_cycle)

            touch_copied_records(rolled_over_provider)
          end
        end
      end

      result
    end

  private

    attr_reader :copy_course_to_provider_service,
                :copy_schools_to_provider_service,
                :copy_site_to_provider_service,
                :copy_partnership_to_provider_service,
                :force

    # `sites` and `study_sites` count what this run created. `*_already_present`
    # counts what the destination provider already had, which is the normal
    # outcome of a repeat run and not a problem. `*_skipped` is reserved for
    # copies that were attempted and failed — rollover reporting surfaces those
    # for support to act on, so nothing else belongs in them.
    def init_result_hash
      {
        providers: 0,
        sites: 0,
        sites_already_present: 0,
        study_sites: 0,
        study_sites_already_present: 0,
        courses: 0,
        partnerships: 0,
        courses_failed: [],
        courses_skipped: [],
        sites_skipped: [],
        study_sites_skipped: [],
      }
    end

    def provider_eligible?(provider)
      provider.rollable? || force
    end

    def find_or_create_provider_in_cycle(provider, new_recruitment_cycle, result)
      rolled_over_provider = new_recruitment_cycle.providers.find_by(provider_code: provider.provider_code)
      unless rolled_over_provider
        rolled_over_provider = duplicate_provider(provider, new_recruitment_cycle)
        result[:providers] = 1
      end
      rolled_over_provider
    end

    def duplicate_provider(provider, new_recruitment_cycle)
      rolled = provider.dup
      rolled.organisations << provider.organisations
      rolled.ucas_preferences = provider.ucas_preferences.dup
      rolled.contacts << provider.contacts.map(&:dup)
      rolled.recruitment_cycle = new_recruitment_cycle
      rolled.skip_geocoding = true
      rolled.users << provider.users
      rolled.save!
      rolled
    end

    def copy_schools(provider, new_provider, result)
      school_result = copy_schools_to_provider_service.execute(provider:, new_provider:)
      result[:sites] += school_result[:copied]
      result[:sites_already_present] += school_result.fetch(:already_present, []).size
      result[:sites_skipped].concat(school_result[:skipped])
    end

    # Study sites already on the destination provider are filtered out before the
    # orchestrator sees them: it hands out codes from a finite pool, and which
    # branch it takes depends on the list it is given, so passing sites we are
    # about to skip would burn codes and shift the codes it assigns to the rest.
    def copy_study_sites(provider, new_provider, result)
      existing_sites = Sites::ExistingSiteIndex.for(provider: new_provider, site_type: :study_site)
      sites_to_copy, already_present = provider.study_sites.partition { !existing_sites.already_copied?(it) }
      result[:study_sites_already_present] += already_present.size

      assignments = DataHub::Rollover::StudySiteCodeOrchestrator.new(
        target_provider: new_provider,
        sites_to_copy:,
      ).call

      assignments.each do |assignment|
        site = assignment[:site]
        code = assignment[:code]
        site_result = copy_site_to_provider_service.execute(
          site: site,
          new_provider: new_provider,
          assigned_code: code,
        )
        save_site_result(site_result:, result:, count_key: :study_sites, skip_key: :study_sites_skipped, site_code: code)
      end
    end

    def save_site_result(site_result:, result:, count_key:, skip_key:, site_code:)
      if site_result.success?
        result[count_key] += 1
      else
        result[skip_key] << { site_code: site_code, reason: site_result.error_message }
      end
    end

    def copy_courses(provider, new_provider, course_codes, result)
      eligible = if force
                   course_codes ? provider.courses.where(course_code: course_codes.map(&:upcase)) : []
                 else
                   course_codes ? provider.courses.where(course_code: course_codes.map(&:upcase)) : provider.courses
                 end

      if course_codes && (eligible.size != course_codes.size)
        msg = "Error: discrepancy between courses found and provided course codes (#{eligible.size} vs #{course_codes.size})"
        Rails.logger.fatal(msg)
        raise msg
      end

      eligible.each do |course|
        copy_course_to_provider_service.execute(course: course, new_provider: new_provider)
        result[:courses] += 1
      rescue StandardError => e
        result[:courses_failed] << { course_code: course.course_code, error_message: e.message }
      end
    end

    # Stands in for the per-record touches suppressed during the copy.
    #
    # Only the provider needs stamping. Every course here is newly inserted, and
    # Rails sets `changed_at` on create, so re-stamping them would be redundant
    # and would risk colliding on its unique index. The provider may already have
    # existed in the destination cycle, in which case nothing else updates it.
    def touch_copied_records(rolled_over_provider)
      rolled_over_provider.update_changed_at
    end

    def copy_partnerships(provider, rolled_over_provider, new_recruitment_cycle)
      copy_partnership_to_provider_service.execute(
        provider: provider,
        rolled_over_provider: rolled_over_provider,
        new_recruitment_cycle: new_recruitment_cycle,
      )
    end
  end
end
