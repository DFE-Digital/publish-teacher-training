# == Schema Information
#
# Table name: course_site
#
#  course_id  :integer
#  id         :integer          not null, primary key
#  publish    :text
#  site_id    :integer
#  status     :text
#  vac_status :text
#
# Indexes
#
#  IX_course_site_course_id         (course_id)
#  IX_course_site_site_id           (site_id)
#  index_course_site_on_publish     (publish)
#  index_course_site_on_status      (status)
#  index_course_site_on_vac_status  (vac_status)
#

class SiteStatus < ApplicationRecord
  include TouchCourse
  include AASM

  self.table_name = "course_site"

  after_initialize :set_defaults
  before_validation :set_vac_status

  audited associated_with: :course

  validate :vac_status_must_be_consistent_with_course_study_mode,
           if: Proc.new { |s| s.course&.study_mode.present? }

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

  aasm column: :status, enum: true do
    state :new_status, initial: true
    state :running
    state :suspended
    state :discontinued

    after_all_transitions :update_publish_flag

    event :start do
      transitions from: %i[new_status suspended discontinued], to: :running
    end

    event :suspend do
      transitions from: :running, to: :suspended
    end
  end

  def update_publish_flag
    self.publish = (aasm.to_state == :running ? :published : :unpublished)
  end

  belongs_to :site
  belongs_to :course

  acts_as_mappable through: :site
  scope :findable, -> { status_running.published_on_ucas }

  def findable?
    status_running? && published_on_ucas?
  end

  scope :with_vacancies, -> { where.not(vac_status: :no_vacancies) }
  def with_vacancies?
    !no_vacancies?
  end

  def self.default_vac_status_given(study_mode:)
    case study_mode
    when "full_time"
      :full_time_vacancies
    when "part_time"
      :part_time_vacancies
    when "full_time_or_part_time"
      :both_full_time_and_part_time_vacancies
    else
      raise "Unexpected study mode #{study_mode}"
    end
  end

  def has_vacancies?
    with_vacancies?
  end

private

  def set_defaults
    self.status ||= :new_status
    self.publish ||= :unpublished
  end

  def set_vac_status
    self.vac_status ||= self.class.default_vac_status_given(study_mode: course.study_mode)
  end

  def vac_status_must_be_consistent_with_course_study_mode
    unless vac_status_consistent_with_course_study_mode?
      errors.add(:vac_status, "(#{vac_status}) must be consistent with course study mode #{course.study_mode}")
    end
  end

  def vac_status_consistent_with_course_study_mode?
    case vac_status
    when "no_vacancies"
      true
    when "full_time_vacancies"
      course.full_time? || course.full_time_or_part_time?
    when "part_time_vacancies"
      course.part_time? || course.full_time_or_part_time?
    when "both_full_time_and_part_time_vacancies"
      course.full_time_or_part_time?
    else
      false
    end
  end
end
