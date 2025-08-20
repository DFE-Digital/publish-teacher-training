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
        safe_copy_site(site, new_provider, result, :sites)
      end
    end

    def copy_study_sites(provider, new_provider, result)
      provider.study_sites.each do |site|
        safe_copy_site(site, new_provider, result, :study_sites)
      end
    end

    def safe_copy_site(site, new_provider, result, count_key)
      site_result = copy_site_to_provider_service.execute(site: site, new_provider: new_provider)

      if site_result.success?
        result[count_key] += 1
      else
        result[:study_sites_skipped] << {
          site_code: site.code,
          reason: site_result.error_message,
        }
      end
    end

    def copy_courses(provider, new_provider, course_codes, result)
      eligible_courses = courses_to_copy(provider, course_codes)
      eligible_courses.each do |course|
        safe_copy_course(course, new_provider, result)
      end
    end

    def safe_copy_course(course, new_provider, result)
      new_course = copy_course_to_provider_service.execute(course: course, new_provider: new_provider)
      if new_course.present?
        result[:courses] += 1
      else
        result[:courses_skipped] << { course_code: course.course_code, reason: "not rollable or duplicate on provider" }
      end
    rescue StandardError => e
      result[:courses_failed] << { course_code: course.course_code, error_message: e.message }
    end

    def copy_partnerships(provider, rolled_over_provider, new_recruitment_cycle)
      copy_partnership_to_provider_service.execute(
        provider: provider,
        rolled_over_provider: rolled_over_provider,
        new_recruitment_cycle: new_recruitment_cycle,
      )
    end

    def courses_to_copy(provider, course_codes)
      if force
        if course_codes.nil?
          []
        else
          courses_from_course_codes(provider, course_codes)
        end
      elsif course_codes.nil?
        provider.courses
      else
        courses_from_course_codes(provider, course_codes)
      end
    end

    def courses_from_course_codes(provider, course_codes)
      courses = provider.courses.where(course_code: course_codes.to_a.map(&:upcase))
      unless courses.count == course_codes.count
        error_message = "Error: discrepancy between courses found and provided course codes (#{courses.count} vs #{course_codes.count})"
        Rails.logger.fatal error_message
        raise error_message
      end
      courses
    end
  end
end
