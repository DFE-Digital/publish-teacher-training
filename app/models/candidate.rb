class Candidate < ApplicationRecord
  validates :email_address, email_address: true

  normalizes :email_address, with: ->(value) { value&.strip&.downcase }, apply_to_nil: false

  has_many :sessions, inverse_of: :sessionable
end
