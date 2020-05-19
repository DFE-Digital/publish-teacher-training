class SubjectArea < ApplicationRecord
  has_many :subjects, foreign_key: :type, inverse_of: :subject_area
  self.primary_key = :typename
  scope :active, -> { where.not(typename: "DiscontinuedSubject") }
end
