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

  # See Course association "modern_languages_subject" ... that should be using
  # a scope as below.
  #
  # scope :primary_subjects, -> { where(type: "PrimarySubject") }
  # scope :secondary_subjects, -> { where(type: "SecondarySubject") }
  # scope :modern_languages, -> { where(type: "ModernLanguagesSubject") }
  # scope :further_education, -> { where(type: "FurtherEducationSubject") }

  def to_sym
    subject_name.parameterize.underscore.to_sym
  end

  def to_s
    subject_name
  end

  # def primary_subject?
  #   type == "PrimarySubject"
  # end

  def secondary_subject?
    type == "SecondarySubject"
  end

  # def modern_languages_subject?
  #   type == "ModernLanguagesSubject"
  # end

  # def further_education_subject?
  #   type == "FutherEducationSubject"
  # end
end
