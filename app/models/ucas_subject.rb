# == Schema Information
#
# Table name: subject
#
#  id           :bigint           not null, primary key
#  type         :text
#  subject_code :text
#  subject_name :text
#

class UCASSubject < ApplicationRecord
  has_many :course_ucas_subjects
  has_many :courses, through: :course_ucas_subjects

  scope :further_education, -> { where(subject_name: 'Further Education') }

  def is_send?
    subject_code.casecmp('U3').zero?
  end

  def to_s
    subject_name
  end
end
