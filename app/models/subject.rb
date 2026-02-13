# frozen_string_literal: true

class Subject < ApplicationRecord
  has_many :course_subjects
  has_many :courses, through: :course_subjects
  belongs_to :subject_group, optional: true
  belongs_to :subject_area, foreign_key: :type, inverse_of: :subjects
  has_one :financial_incentive

  scope :with_subject_codes, lambda { |subject_codes|
    where(subject_code: subject_codes)
  }

  scope :active, -> { where.not(type: "DiscontinuedSubject") }
  scope :primary, -> { where(type: "PrimarySubject").order(:subject_name) }
  scope :secondary, lambda {
    where(type: %w[SecondarySubject ModernLanguagesSubject])
      .where.not(subject_name: ["Modern Languages"])
      .order(:subject_name)
  }

  def name
    subject_name
  end

  def self.primary_subject_codes
    primary.pluck(:subject_code)
  end

  def self.secondary_subject_codes_with_incentives
    secondary.includes(:financial_incentive).pluck(:subject_code)
  end

  def self.secondary_subjects_with_subject_groups
    secondary
      .where.not(subject_group: nil)
      .includes(:subject_group)
      .reorder("subject_group.created_at ASC, subject.subject_name ASC")
  end

  def secondary_subject?
    type == "SecondarySubject"
  end

  LANGUAGE_SUBJECT_CODES = %w[Q3 A1 A2 15 18 19 A0 20 21 22 17].freeze
  def language_subject?
    subject_code.in?(LANGUAGE_SUBJECT_CODES)
  end

  def physics?
    subject_name == "Physics"
  end

  # Subjects where non-UK citizens are eligible for bursaries only
  NON_UK_BURSARY_ELIGIBLE_NAMES = [
    "Italian",
    "Japanese",
    "Mandarin",
    "Russian",
    "Modern languages (other)",
    "Ancient Greek",
    "Ancient Hebrew",
  ].freeze

  def non_uk_bursary_eligible?
    subject_name.in?(NON_UK_BURSARY_ELIGIBLE_NAMES)
  end

  # Subjects where non-UK citizens are eligible for scholarships and bursaries
  NON_UK_SCHOLARSHIP_AND_BURSARY_ELIGIBLE_NAMES = %w[
    Physics
    French
    German
    Spanish
  ].freeze

  def non_uk_scholarship_and_bursary_eligible?
    subject_name.in?(NON_UK_SCHOLARSHIP_AND_BURSARY_ELIGIBLE_NAMES)
  end

  # Maps subject codes to I18n keys for scholarship bodies
  SCHOLARSHIP_BODY_MAP = {
    "F1" => "chemistry",
    "11" => "computing",
    "G1" => "mathematics",
    "F3" => "physics",
    "15" => "french",
    "17" => "german",
    "22" => "spanish",
  }.freeze

  def scholarship_body_key
    SCHOLARSHIP_BODY_MAP[subject_code]
  end

  def match_synonyms_text
    return "" if match_synonyms.blank?

    Array(match_synonyms).compact_blank.join("\n")
  end

  def to_sym
    subject_name.parameterize.underscore.to_sym
  end

  def to_s
    subject_name
  end
end
