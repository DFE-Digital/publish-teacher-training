# frozen_string_literal: true

module Sandbox
  # Gives a course the schools it has in production, keeping production's
  # site codes. Takes the locations from the public Publish API.
  #
  # A GIAS school that this environment doesn't have is created from the
  # location's details. A location that clashes with a school the provider
  # already has here is reported as a conflict and skipped: sandbox codes
  # are never rewritten.
  class ImportCourseSchools
    include ServicePattern

    Result = Struct.new(:schools_created, :gias_stubs, :conflicts, keyword_init: true)

    def initialize(course:, locations:)
      @course = course
      @provider = course.provider
      @locations = locations
      @result = Result.new(schools_created: [], gias_stubs: [], conflicts: [])
    end

    def call
      @locations.each { |location| import(location["attributes"]) }
      @result
    end

  private

    def import(location)
      gias_school = find_or_create_gias_school(location)
      provider_school = find_or_create_provider_school(gias_school, location)
      return if provider_school.nil?

      @course.schools.find_or_create_by!(provider_school:) do |course_school|
        course_school.gias_school = gias_school
      end
    end

    def find_or_create_gias_school(location)
      GiasSchool.find_by(urn: location["urn"]) || create_gias_school(location)
    end

    def find_or_create_provider_school(gias_school, location)
      site_code = location["code"]
      existing = @provider.schools.find_by(gias_school:, site_code:)
      return existing if existing

      if (other = @provider.schools.find_by(gias_school:))
        return conflict(location, "the provider already has this school with code #{other.site_code}")
      end

      if @provider.schools.exists?(site_code:)
        return conflict(location, "the provider already has a school with code #{site_code}")
      end

      @result.schools_created << label(location)
      @provider.schools.create!(gias_school:, site_code:)
    end

    def create_gias_school(location)
      @result.gias_stubs << location["urn"]

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

    def conflict(location, reason)
      @result.conflicts << "#{label(location)}: #{reason}"
      nil
    end

    def label(location)
      "#{location['code']} (#{location['urn']})"
    end
  end
end
