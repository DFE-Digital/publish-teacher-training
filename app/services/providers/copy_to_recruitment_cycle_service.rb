# frozen_string_literal: true

module Providers
  class CopyToRecruitmentCycleService
    def initialize(copy_course_to_provider_service:, copy_site_to_provider_service:, copy_partnership_to_provider_service:, force:)
      @copy_course_to_provider_service = copy_course_to_provider_service
      @copy_site_to_provider_service = copy_site_to_provider_service
      @copy_partnership_to_provider_service = copy_partnership_to_provider_service
      @force = force
    end

    def execute(provider:, new_recruitment_cycle:, course_codes: nil)
      result = init_result_hash

      if provider_eligible?(provider)
        ActiveRecord::Base.transaction do
          rolled_over_provider = find_or_create_provider_in_cycle(provider, new_recruitment_cycle, result)

          copy_sites(provider, rolled_over_provider, result)
          copy_study_sites(provider, rolled_over_provider, result)
          copy_courses(provider, rolled_over_provider, course_codes, result)
          result[:partnerships] = copy_partnerships(provider, rolled_over_provider, new_recruitment_cycle)
        end
      end

      result
    end

  private

    attr_reader :copy_course_to_provider_service, :copy_site_to_provider_service, :copy_partnership_to_provider_service, :force

    def init_result_hash
      {
        providers: 0,
        sites: 0,
        study_sites: 0,
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

    def copy_sites(provider, new_provider, result)
      provider.sites.each do |site|
        site_result = copy_site_to_provider_service.execute(site: site, new_provider: new_provider)
        save_site_result(site_result: site_result, result: result, count_key: :sites, skip_key: :sites_skipped, site_code: site.code)
      end
    end

    def copy_study_sites(provider, new_provider, result)
      assignments = DataHub::Rollover::StudySiteCodeOrchestrator.new(
        target_provider: new_provider,
        sites_to_copy: provider.study_sites,
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

    def copy_partnerships(provider, rolled_over_provider, new_recruitment_cycle)
      copy_partnership_to_provider_service.execute(
        provider: provider,
        rolled_over_provider: rolled_over_provider,
        new_recruitment_cycle: new_recruitment_cycle,
      )
    end
  end
end
