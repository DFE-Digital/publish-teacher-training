# frozen_string_literal: true

class GiasSchool < ApplicationRecord
  include PgSearch::Model
  include VectorSearchable

  ESTABLISHMENT_OPEN_STATUS_CODE = '1'

  validates :urn, :name, :address1, :town, :postcode, presence: true
  validates :urn, uniqueness: { case_sensitive: false }

  pg_search_scope :search,
                  against: %i[urn name town postcode],
                  using: {
                    tsearch: {
                      prefix: true,
                      tsvector_column: 'searchable'
                    }
                  }

  scope :open, -> { where(status_code: ESTABLISHMENT_OPEN_STATUS_CODE) }

  def school_attributes
    {
      location_name: name,
      urn:,
      code: urn,
      address1:,
      address2:,
      address3:,
      town:,
      address4: county,
      postcode:
    }
  end

  private

  def searchable_vector_value
    [
      urn,
      name,
      name_normalised,
      postcode,
      postcode&.delete(' '),
      town
    ].join(' ')
  end

  def name_normalised = StripPunctuationService.call(string: name)
end
