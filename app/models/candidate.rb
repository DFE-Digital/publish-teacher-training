class Candidate < ApplicationRecord
  validates :email_address, email_address: true

  normalizes :email_address, with: ->(value) { value&.strip&.downcase }, apply_to_nil: false

  has_many :sessions, inverse_of: :sessionable

  has_many :saved_courses, dependent: :destroy
  has_many :saved_course_records, through: :saved_courses, source: :course

  def full_name
    email_address
  end
end
