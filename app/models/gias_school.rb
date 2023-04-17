# frozen_string_literal: true

class GiasSchool < ApplicationRecord
  include PgSearch::Model

  ESTABLISHMENT_OPEN_STATUS_CODE = '1'

  validates :urn, :name, :address1, :town, :postcode, presence: true
  validates :urn, uniqueness: { case_sensitive: false }

  before_save :update_searchable

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

  # The below generates a query like:
  #
  #      TO_TSVECTOR(
  #        'pg_catalog.simple',
  #        '1000000 St Mary''s School ec3a 5de ec3a5de London'
  #      );
  #
  # and assigns the result to the "searchable" field, which is used by pg_search_scope above.
  # This creates a space seperated string with all the searchable info about a school such as:
  #   "1000000 St Marys School ec3a 5de ec3a5de London"
  #
  # Special characters are stripped off in the search to ensure that a search matches with
  # or without them, for example, searching by "mary's" or "marys" will have results including
  # St Mary's
  #
  # The reason for mentioning the postcode twice is that postgres will split text up by spaces
  # into "words" when converting it into a tsvector. We would like someone to be able to type
  # a postcode without spaces and still get a result. Without doing this, the searchable
  # vector would look like this:
  #   "'100000':1 '5de':6 'aldgate':3 'ec3a':5 'london':8 'school':4 'the':2"
  #
  # searching for ec3a5de would not match any results as it only matches if a query term is exact, or
  # a prefix of a word. With the above query we end up with a vector like this:
  #   "'100000':1 '5de':6 'aldgate':3 'ec3a':5 'ec3a5de':7 'london':8 'school':4 'the':2"
  #
  def update_searchable
    ts_vector_value = [
      urn,
      name,
      name_normalised,
      postcode,
      postcode&.delete(' '),
      town
    ].join(' ')

    to_tsvector = Arel::Nodes::NamedFunction.new(
      'TO_TSVECTOR', [
        Arel::Nodes::Quoted.new('pg_catalog.simple'),
        Arel::Nodes::Quoted.new(ts_vector_value)
      ]
    )

    self.searchable =
      ActiveRecord::Base
      .connection
      .execute(Arel::SelectManager.new.project(to_tsvector).to_sql)
      .first
      .values
      .first
  end

  def name_normalised
    StripPunctuationService.call(string: name)
  end
end
