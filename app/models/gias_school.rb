# frozen_string_literal: true

class GiasSchool < ApplicationRecord
  include PgSearch::Model
  include VectorSearchable

  validates :urn, :name, presence: true
  validates :urn, uniqueness: { case_sensitive: false }

  pg_search_scope :search,
                  against: %i[urn name town postcode],
                  using: {
                    tsearch: {
                      prefix: true,
                      tsvector_column: "searchable",
                    },
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
