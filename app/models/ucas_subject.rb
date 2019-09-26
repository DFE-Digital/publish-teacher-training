# == Schema Information
#
# Table name: ucas_subject
#
#  id           :integer          not null, primary key
#  subject_name :text
#  subject_code :text             not null
#

# TODO: this can be removed ucas subjects related
class UCASSubject < ApplicationRecord
  has_many :course_ucas_subjects
  has_many :courses, through: :course_ucas_subjects

  scope :further_education, -> { where(subject_name: "Further Education") }

  def is_send?
    subject_code.casecmp("U3").zero?
  end

  def to_s
    subject_name
  end
end
