class Import < ApplicationRecord
  enum :import_type, {
    register_schools: 0,
  }

  validates :short_summary, presence: true
  validates :full_summary, presence: true
  validates :import_type, presence: true
end
