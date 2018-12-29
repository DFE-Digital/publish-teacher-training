class Course < ApplicationRecord
  self.table_name = "course"

  belongs_to :provider
  belongs_to :accrediting_provider, class_name: 'Provider', optional: true
end
