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
    before_create :update_searchable
  end

  private

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
