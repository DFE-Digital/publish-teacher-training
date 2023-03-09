# frozen_string_literal: true

class GiasSchool < ApplicationRecord
  validates :urn, :name, :address1, :town, :postcode, presence: true
  validates :urn, uniqueness: { case_sensitive: false }
end
