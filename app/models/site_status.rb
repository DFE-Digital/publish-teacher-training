# == Schema Information
#
# Table name: course_site
#
#  id                         :integer          not null, primary key
#  applications_accepted_from :date
#  course_id                  :integer
#  publish                    :text
#  site_id                    :integer
#  status                     :text
#  vac_status                 :text
#

class SiteStatus < ApplicationRecord
  self.table_name = "course_site"

  enum vac_status: {
    both_full_time_and_part_time_vacancies: "B",
    part_time_vacancies: "P",
    full_time_vacancies: "F",
    no_vacancies: "",
  }

  enum status: {
    discontinued: "D",
    running: "R",
    new_status: "N",
    suspended: "S",
  }, _prefix: :status

  enum publish: {
    published: "Y",
    unpublished: "N",
  }, _suffix: :on_ucas

  belongs_to :site
  belongs_to :course

  scope :findable, -> { status_running.published_on_ucas }
  scope :applications_being_accepted_now, -> {
    where.not(applications_accepted_from: nil).
    where('applications_accepted_from <= ?', Time.now.utc)
  }
  scope :with_vacancies, -> { where.not(vac_status: :no_vacancies) }
  scope :open_for_applications, -> { findable.applications_being_accepted_now.with_vacancies }
end
