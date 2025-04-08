# frozen_string_literal: true

class PotentialDate
  include ActiveModel::Model
  attr_accessor :year, :month, :day
end
