# == Schema Information
#
# Table name: subject_area
#
#  created_at :datetime         not null
#  name       :text
#  typename   :text             not null, primary key
#  updated_at :datetime         not null
#
# Indexes
#
#  index_subject_area_on_typename  (typename)
#

class SubjectArea < ApplicationRecord
  has_many :subjects, foreign_key: :type, inverse_of: :subject_area
  self.primary_key = :typename
  scope :active, -> { where.not(typename: "DiscontinuedSubject") }
end
