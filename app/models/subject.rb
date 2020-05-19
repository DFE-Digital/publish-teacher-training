class Subject < ApplicationRecord
  has_many :course_subjects
  has_many :courses, through: :course_subjects
  belongs_to :subject_area, foreign_key: :type, inverse_of: :subjects
  has_one :financial_incentive

  scope :with_subject_codes, ->(subject_codes) do
    where(subject_code: subject_codes)
  end

  scope :active, -> { where.not(type: "DiscontinuedSubject") }

  def secondary_subject?
    type == "SecondarySubject"
  end

  def to_sym
    subject_name.parameterize.underscore.to_sym
  end

  def to_s
    subject_name
  end
end
