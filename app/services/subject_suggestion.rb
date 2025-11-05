# frozen_string_literal: true

class SubjectSuggestion
  include ActiveModel::Model

  attr_accessor :name, :value, :match_synonyms
end
