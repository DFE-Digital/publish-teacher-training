# == Schema Information
#
# Table name: subject
#
#  id           :integer          not null, primary key
#  subject_name :text
#  subject_code :text             not null
#

class Subject < ApplicationRecord
  has_many :course_subjects
  has_many :courses, through: :course_subjects

  scope :further_education, -> { where(subject_name: 'Further Education') }

  def is_send?
    subject_code.casecmp('U3').zero?
  end

  def to_s
    subject_name
  end
end
