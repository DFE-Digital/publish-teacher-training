# == Schema Information
#
# Table name: subject
#
#  created_at      :datetime
#  id              :bigint           not null, primary key
#  subject_area_id :bigint
#  subject_code    :text
#  subject_name    :text
#  type            :text
#  updated_at      :datetime
#
# Indexes
#
#  index_subject_on_subject_area_id  (subject_area_id)
#  index_subject_on_subject_name     (subject_name)
#

class Subject < ApplicationRecord
  has_many :course_subjects
  has_many :courses, through: :course_subjects
  belongs_to :subject_area, foreign_key: :type, inverse_of: :subjects
  has_one :financial_incentive

  def to_sym
    subject_name.parameterize.underscore.to_sym
  end

  def to_s
    subject_name
  end

  def secondary_subject?
    type == "SecondarySubject"
  end
end
