# frozen_string_literal: true

module Configs
  class CourseInformation
    def initialize(course)
      @db = Rails.application.config_for(:course_information)
      @course = course
    end

    def show_placement_guidance?(type)
      case type
      when :provider_type
        subtype = @course.provider.provider_type
      when :program_type
        subtype = @course.program_type
      end

      @db.dig(:placements, type, subtype.to_sym, :except_provider_codes)&.exclude?(@course.provider.provider_code)
    end

    def contact_form
      @db.fetch(:contact_forms).stringify_keys[@course.provider.provider_code]
    end

    def contact_form?
      @db.fetch(:contact_forms).stringify_keys.include?(@course.provider.provider_code)
    end

    def show_address?
      @db.dig(:show_address, :only_provider_codes).include?(@course.provider.provider_code) &&
        @db.dig(:show_address, :only_course_codes).include?(@course.course_code)
    end
  end
end
