class SiteStatus < ApplicationRecord
  self.table_name = "course_site"

  enum vac_status: {
    "Both full time and part time vacancies" => "B",
    "Part time vacancies" => "P",
    "Full time vacancies" => "F",
    "No vacancies" => "",
  }

  belongs_to :site
  belongs_to :course
end
