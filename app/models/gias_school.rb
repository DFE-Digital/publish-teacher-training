# frozen_string_literal: true

class GiasSchool < ApplicationRecord
  include PgSearch::Model
  include VectorSearchable

  validates :urn, :name, presence: true
  validates :urn, uniqueness: { case_sensitive: false }

  acts_as_mappable lat_column_name: :latitude, lng_column_name: :longitude

  pg_search_scope :search,
                  against: %i[urn name town postcode],
                  using: {
                    tsearch: {
                      prefix: true,
                      tsvector_column: "searchable",
                    },
                  }

  # Which GIAS education phases belong to each course level. Providers were
  # being offered every school in their account regardless of the course, so a
  # secondary course listed primary schools.
  PHASE_CODES_FOR_COURSE_LEVEL = {
    "primary" => %w[nursery primary middle_deemed_primary all_through],
    "secondary" => %w[secondary middle_deemed_secondary all_through],
    "further_education" => %w[sixteen_plus],
  }.freeze

  # StatutoryLowAge/StatutoryHighAge arrive as free text: "3", "11", "", nil,
  # and occasionally something non-numeric. Strip every non-digit then NULLIF,
  # so a value with no digits becomes NULL rather than raising on ::int.
  #
  # Deliberately not a CASE guard — Postgres does not promise that a CASE
  # condition is evaluated before the cast in its branch, so a guarded cast can
  # still raise 22P02. regexp_replace + NULLIF cannot.
  MINIMUM_AGE_SQL = "NULLIF(regexp_replace(COALESCE(gias_school.minimum_age, ''), '[^0-9]', '', 'g'), '')::int"
  MAXIMUM_AGE_SQL = "NULLIF(regexp_replace(COALESCE(gias_school.maximum_age, ''), '[^0-9]', '', 'g'), '')::int"

  # "Not applicable" is the largest phase in GIAS, so it is segmented by age
  # range instead. More than one of these can be true for the same school.
  NOT_APPLICABLE_AGE_PREDICATES = {
    "primary" => "#{MINIMUM_AGE_SQL} <= 8",
    "secondary" => "(#{MINIMUM_AGE_SQL} BETWEEN 9 AND 14) " \
                   "OR (#{MINIMUM_AGE_SQL} <= 9 AND #{MAXIMUM_AGE_SQL} >= 15)",
    "further_education" => "#{MINIMUM_AGE_SQL} >= 15",
  }.freeze

  # Schools relevant to a course of this level. Fails open: a school we cannot
  # classify — no phase code, a code this enum does not know, or "not
  # applicable" with no usable age range — shows on every level, so a provider
  # never loses access to a school because of a GIAS data gap.
  scope :for_course_level, lambda { |level|
    phase_codes_for_level = PHASE_CODES_FOR_COURSE_LEVEL[level.to_s]
    next all if phase_codes_for_level.nil?

    # The outer parentheses are load-bearing: Rails ANDs raw-SQL fragments onto
    # a relation without wrapping them, so an unparenthesised disjunction here
    # would swallow every other condition.
    where(
      <<~SQL.squish,
        (
          gias_school.phase_code IN (:in_phase)
          OR gias_school.phase_code IS NULL
          OR gias_school.phase_code NOT IN (:known_phases)
          OR (
            gias_school.phase_code = :not_applicable
            AND (
              #{MINIMUM_AGE_SQL} IS NULL
              OR (#{NOT_APPLICABLE_AGE_PREDICATES.fetch(level.to_s)})
            )
          )
        )
      SQL
      in_phase: phase_codes.values_at(*phase_codes_for_level),
      known_phases: phase_codes.values,
      not_applicable: phase_codes[:not_applicable],
    )
  }

  scope :available, lambda {
    where(status_code: [
      GiasSchool.status_codes[:open],
      GiasSchool.status_codes[:proposed_to_open],
      GiasSchool.status_codes[:proposed_to_close],
    ])
  }

  enum :status_code, {
    open: "1",
    closed: "2",
    proposed_to_close: "3",
    proposed_to_open: "4",
  }

  enum :type_code, {
    community_school: "01",
    voluntary_aided_school: "02",
    voluntary_controlled_school: "03",
    foundation_school: "05",
    city_technical_college: "06",
    community_special_school: "07",
    non_maintained_special_school: "08",
    other_independent_special_school: "10",
    other_independent_school: "11",
    other_foundation_school: "12",
    pupil_referral_unit: "14",
    local_authority_nursery_school: "15",
    further_education: "18",
    secure_units: "24",
    offshore_units: "25",
    service_childrens_education: "26",
    miscellaneous: "27",
    academy_sponsor_led: "28",
    heis: "29",
    welsh_establishment: "30",
    sixth_form_centres: "31",
    special_post_16_intitutions: "32",
    academy_special_sponsor_led: "33",
    academy_converter: "34",
    free_schools: "35",
    free_special_schools: "36",
    british_schools_overseas: "37",
    free_schools_alternative_provision: "38",
    free_schools_16_to_19: "39",
    university_technical_colleges: "40",
    studio_schools: "41",
    academy_alternative_provider_converter: "42",
    academy_alternative_provision_sponsor_led: "43",
    academy_special_converter: "44",
    academy_16_to_19_converter: "45",
    academy_16_to_19_sponsor_led: "46",
    online_provider: "49",
    institute_funded_by_other_gov_dept: "56",
    academy_secure_16_to_19: "57",
  }, suffix: :type

  enum :group_code, {
    colleges: "1",
    universities: "2",
    independent_schools: "3",
    local_authority_schools: "4",
    special_schools: "5",
    welsh_schools: "6",
    other_types: "9",
    academies: "10",
    free_schools: "11",
    online_provider: "13",
  }

  enum :phase_code, {
    not_applicable: "0",
    nursery: "1",
    primary: "2",
    middle_deemed_primary: "3",
    secondary: "4",
    middle_deemed_secondary: "5",
    sixteen_plus: "6",
    all_through: "7",
  }

  enum :region_code, {
    north_east: "A",
    north_west: "B",
    yorkshire_and_the_humber: "D",
    east_midlands: "E",
    west_midlands: "F",
    east_of_england: "G",
    london: "H",
    south_east: "J",
    south_west: "K",
    not_applicable: "Z",
  }, prefix: true

  def school_attributes
    {
      location_name: name,
      urn:,
      address1:,
      address2:,
      address3:,
      town:,
      address4: county,
      postcode:,
    }
  end

  def full_address
    [name, address1, address2, address3, town, postcode].compact_blank.join(", ")
  end

private

  def searchable_vector_value
    [
      urn,
      name,
      name_normalised,
      postcode,
      postcode&.delete(" "),
      town,
    ].join(" ")
  end

  def name_normalised = StripPunctuationService.call(string: name)
end
