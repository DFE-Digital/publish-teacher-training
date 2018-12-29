class Course < ApplicationRecord
  self.table_name = "course"

  belongs_to :provider
  belongs_to :accrediting_provider, class_name: 'Provider', optional: true
  has_and_belongs_to_many :subjects
end
