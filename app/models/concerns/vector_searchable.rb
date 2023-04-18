# frozen_string_literal: true

# Include this module in any model that needs to be searchable using pg_search with a tsvector column
# This module will automatically update the searchable field when the model is saved.
#
# To use this module, you must have a searchable field in your model.
#
# Example:
#
# class Model < ApplicationRecord
#   include PgSearch::Model
#   include VectorSearchable
#
#   pg_search_scope :search,
#                   against: %i[urn name town postcode],
#                   using: {
#                     tsearch: {
#                       prefix: true,
#                       tsvector_column: 'searchable'
#                     }
#                   }
#
#
#   private
#
#   def searchable_vector_value
#     # define this in the including model
#   end
# end
#
# The searchable_vector_value method should return a string that will be used to generate the
# tsvector column. The string should be space seperated and contain all the searchable fields
# that you want to be included in the search.
module VectorSearchable
  extend ActiveSupport::Concern

  included do
    before_save :update_searchable
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
    to_tsvector = Arel::Nodes::NamedFunction.new(
      'TO_TSVECTOR', [
        Arel::Nodes::Quoted.new('pg_catalog.simple'),
        Arel::Nodes::Quoted.new(searchable_vector_value)
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

  def searchable_vector_value
    raise NotImplementedError('#searchable_vector_value must be implemented in the including model')
  end
end
