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

  ALLOWED_VAC_STATUSES = {
    nil                      => %w[no_vacancies],
    'full_time'              => %w[no_vacancies full_time_vacancies],
    'part_time'              => %w[no_vacancies part_time_vacancies],
    'full_time_or_part_time' => %w[no_vacancies part_time_vacancies full_time_vacancies both_full_time_and_part_time_vacancies],
  }.freeze

  validate :validate_vac_status, if: :vac_status_changed?

  def validate_vac_status
    unless ALLOWED_VAC_STATUSES[self.course.study_mode].include? vac_status
      errors.add(:vac_status,
        "can only be #{ALLOWED_VAC_STATUSES[self.course.study_mode].map { |s| "'#{s}'" }.join(', ')} as the course study mode is '#{self.course.study_mode}'")
    end
  end

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
