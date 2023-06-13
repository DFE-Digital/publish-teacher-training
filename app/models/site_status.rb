# frozen_string_literal: true

class SiteStatus < ApplicationRecord
  include TouchCourse
  include AASM

  self.table_name = 'course_site'

  after_initialize :set_defaults

  audited associated_with: :course

  enum vac_status: {
    both_full_time_and_part_time_vacancies: 'B',
    part_time_vacancies: 'P',
    full_time_vacancies: 'F',
    no_vacancies: ''
  }

  enum status: {
    discontinued: 'D',
    running: 'R',
    new_status: 'N',
    suspended: 'S'
  }, _prefix: :status

  enum publish: {
    published: 'Y',
    unpublished: 'N'
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

  scope :new_or_running, -> { where(status: %i[running new_status]) }

  def new_or_running?
    status.in?(%w[running new_status])
  end

  private

  def set_defaults
    self.status ||= :new_status
    self.publish ||= :unpublished
  end
end
