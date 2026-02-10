# frozen_string_literal: true

module FundingInformation
  # Subjects where non-UK citizens are eligible for bursaries (but not scholarships)
  NON_UK_BURSARY_ELIGIBLE_SUBJECTS = [
    "Italian",
    "Japanese",
    "Mandarin",
    "Russian",
    "Modern languages (other)",
    "Ancient Greek",
    "Ancient Hebrew",
  ].freeze

  # Subjects where non-UK citizens are eligible for both bursaries and scholarships
  NON_UK_SCHOLARSHIP_ELIGIBLE_SUBJECTS = %w[
    Physics
    French
    German
    Spanish
  ].freeze

  # Subject code → i18n key for scholarship body info (URL, description)
  SCHOLARSHIP_BODY_SUBJECTS = {
    "F1" => "chemistry",
    "11" => "computing",
    "G1" => "mathematics",
    "F3" => "physics",
    "15" => "french",
    "17" => "german",
    "22" => "spanish",
  }.freeze

  # Course name patterns excluded from bursary despite subject eligibility.
  # Only applies to courses with 2 subjects and "with" in the name.
  BURSARY_EXCLUDED_COURSE_PATTERNS = [
    /^Drama/,
    /^Media Studies/,
    /^PE/,
    /^Physical/,
  ].freeze
end
