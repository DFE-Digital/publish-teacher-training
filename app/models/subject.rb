# frozen_string_literal: true

class Subject < ApplicationRecord
  has_many :course_subjects
  has_many :courses, through: :course_subjects
  belongs_to :subject_area, foreign_key: :type, inverse_of: :subjects
  has_one :financial_incentive

  scope :with_subject_codes, lambda { |subject_codes|
    where(subject_code: subject_codes)
  }

  scope :active, -> { where.not(type: 'DiscontinuedSubject') }
  scope :primary, -> { where(type: 'PrimarySubject').order(:subject_name) }
  scope :secondary, lambda {
    where(type: %w[SecondarySubject ModernLanguagesSubject])
      .where.not(subject_name: ['Modern Languages'])
      .order(:subject_name)
  }

  def self.primary_subject_codes
    primary.pluck(:subject_code)
  end

  def self.secondary_subject_codes_with_incentives
    secondary.includes(:financial_incentive).pluck(:subject_code)
  end

  def secondary_subject?
    type == 'SecondarySubject'
  end

  def to_sym
    subject_name.parameterize.underscore.to_sym
  end

  def to_s
    subject_name
  end
end
