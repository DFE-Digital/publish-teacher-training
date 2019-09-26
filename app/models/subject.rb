# == Schema Information
#
# Table name: subject
#
#  id           :bigint           not null, primary key
#  type         :text
#  subject_code :text
#  subject_name :text
#

class Subject < ApplicationRecord
  has_many :course_subjects
  has_many :courses, through: :course_subjects

  def to_sym
    subject_name.parameterize.underscore.to_sym
  end

  def to_s
    "#{subject_name} (#{subject_code})"
  end
end
