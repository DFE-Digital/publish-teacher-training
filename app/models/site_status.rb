class SiteStatus < ApplicationRecord
  self.table_name = "course_site"

  belongs_to :site
  belongs_to :course
end
