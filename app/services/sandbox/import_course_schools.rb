# frozen_string_literal: true

module Sandbox
  # Gives a course the schools it has in production, keeping production's
  # site codes. Takes the locations from the public Publish API.
  #
  # A GIAS school that this environment doesn't have is created from the
  # location's details. A location whose site code the provider already uses
  # here for a different school is reported as a conflict and skipped:
  # sandbox codes are never rewritten. Schools the course has here but not in
  # production are unlinked from the course (the provider keeps them), except
  # those a conflict is about, which are left as they are.
  class ImportCourseSchools
    include ServicePattern

    def initialize(course:, locations:, report: ImportReport.new)
      @course = course
      @provider = course.provider
      @locations = locations
      @report = report
      @kept_ids = []
    end

    def call
      @locations.each { |location| import(location["attributes"]) }
      unlink_schools_not_kept
      @report
    end

  private

    def import(location)
      gias_school = find_or_create_gias_school(location)
      provider_school = find_or_create_provider_school(gias_school, location)
      return if provider_school.nil?

      @course.schools.find_or_create_by!(provider_school:) do |course_school|
        course_school.gias_school = gias_school
      end
      @kept_ids << provider_school.id
    end

    def unlink_schools_not_kept
      extra = @course.schools.where.not(provider_school_id: @kept_ids).includes(:gias_school, :provider_school)

      extra.each do |course_school|
        @report.schools_unlinked << "#{course_school.site_code} (#{course_school.gias_school.urn})"
        course_school.destroy!
      end
    end

    def find_or_create_gias_school(location)
      GiasSchool.find_by(urn: location["urn"]) || create_gias_school(location)
    end

    def find_or_create_provider_school(gias_school, location)
      site_code = location["code"]
      existing = @provider.schools.find_by(gias_school:, site_code:)
      return existing if existing

      # The same school can be under several codes, but a code is one school.
      if @provider.schools.exists?(site_code:)
        return conflict(location, gias_school, "the provider already has a school with code #{site_code}")
      end

      @report.schools_created << label(location)
      uuid = ProductionUuid.keep(location["uuid"], unless_used_by: Provider::School, label: label(location), report: @report)
      @provider.schools.create!(gias_school:, site_code:, uuid:)
    end

    def create_gias_school(location)
      @report.gias_stubs << location["urn"]

      GiasSchool.create!(
        urn: location["urn"],
        name: location["name"].delete_suffix(" (Main site)"),
        address1: location["street_address_1"].presence || location["name"],
        address2: location["street_address_2"].presence,
        address3: location["street_address_3"].presence,
        town: location["city"].presence || "Unknown",
        county: location["county"].presence,
        postcode: location["postcode"],
        region_code: location["region_code"],
        latitude: location["latitude"],
        longitude: location["longitude"],
        status_code: "open",
      )
    end

    # Leaves the course's links to the code and the school alone.
    def conflict(location, gias_school, reason)
      @report.conflicts << "#{label(location)}: #{reason}"
      @kept_ids.concat(@provider.schools.where(site_code: location["code"]).or(@provider.schools.where(gias_school:)).ids)
      nil
    end

    def label(location)
      "#{location['code']} (#{location['urn']})"
    end
  end
end
