class Course < ApplicationRecord
  self.table_name = "course"

  belongs_to :accrediting_provider
  belongs_to :provider
end
