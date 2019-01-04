class Course < ApplicationRecord
  self.table_name = "course"

  enum profpost_flag: {
    "Recommendation for QTS" => "",
    "Professional" => "PF",
    "Postgraduate" => "PG",
    "Professional/Postgraduate" => "BO",
  }

  belongs_to :provider
  belongs_to :accrediting_provider, class_name: 'Provider', optional: true
  has_and_belongs_to_many :subjects
  has_many :site_statuses
  has_many :sites, through: :site_statuses
end
