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

  scope :available, -> { where(status_code: [GiasSchool.status_codes[:open], GiasSchool.status_codes[:proposed_to_close]]) }

  enum :status_code, {
    open: "1",
    closed: "2",
    proposed_to_close: "3",
    proposed_to_open: "4",
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
