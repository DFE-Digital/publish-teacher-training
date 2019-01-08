class Course < ApplicationRecord
  self.table_name = "course"

  enum profpost_flag: {
    "Recommendation for QTS" => "",
    "Professional" => "PF",
    "Postgraduate" => "PG",
    "Professional/Postgraduate" => "BO",
  }

  enum program_type: {
    "Higher education programme" => "HE",
    "School Direct training programme" => "SD",
    "School Direct (salaried) training programme" => "SS",
    "SCITT programme" => "SC",
    "PG Teaching Apprenticeship" => "TA",
  }

  enum study_mode: {
    "full time" => "F",
    "part time" => "P",
    "full time or part time" => "B",
  }

  enum age_range: {
    "primary" => "P",
    "secondary" => "S",
    "middle years" => "M",
    # 'other' doesn't exist in the data yet but is reserved for courses that don't fit
    # the above categories
    "other" => "O",
  }

  belongs_to :provider
  belongs_to :accrediting_provider, class_name: 'Provider', optional: true
  has_and_belongs_to_many :subjects
  has_many :site_statuses
  has_many :sites, through: :site_statuses
end
