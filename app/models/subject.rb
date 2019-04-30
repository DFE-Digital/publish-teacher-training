# == Schema Information
#
# Table name: subject
#
#  id           :integer          not null, primary key
#  subject_name :text
#  subject_code :text             not null
#

class Subject < ApplicationRecord
  has_and_belongs_to_many :courses, join_table: :course_subject

  scope :further_education, -> { where(subject_name: 'Further Education') }

  def is_send?
    subject_code.casecmp('U3').zero?
  end
end
