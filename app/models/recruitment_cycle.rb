# frozen_string_literal: true

class RecruitmentCycle < ApplicationRecord
  has_many :providers, -> { kept }, inverse_of: false
  # Because this is through a has_many, these associations can't be updated,
  # which is a good thing since we don't have a good way to "move" a course or
  # a site to a new recruitment_cycle
  has_many :courses, through: :providers
  has_many :sites, through: :providers
  has_many :study_sites, through: :providers
  validates :year, presence: true

  class << self
    def current_recruitment_cycle!
      find_by!(year: Settings.current_recruitment_cycle_year)
    end

    def current_recruitment_cycle
      find_by(year: Settings.current_recruitment_cycle_year)
    end
    alias_method :current, :current_recruitment_cycle

    def next_recruitment_cycle
      current_recruitment_cycle.next
    end
    alias_method :next, :next_recruitment_cycle
  end

  def self.upcoming_cycles_open_to_publish?
    upcoming_cycles_open_to_publish.exists?
  end

  def self.current_and_upcoming_cycles_open_to_publish
    where(year: Settings.current_recruitment_cycle_year).or(upcoming_cycles_open_to_publish)
  end

  scope :upcoming_cycles_open_to_publish, lambda {
    where("application_start_date > ?", Date.current)
     .where("? BETWEEN available_in_publish_from AND application_start_date", Date.current)
  }

  scope :upcoming_cycles_open_to_support, lambda {
    where("application_start_date > ?", Date.current)
     .where("? BETWEEN available_for_support_users_from AND application_start_date", Date.current)
  }

  def previous
    RecruitmentCycle.find_by(year: year.to_i - 1)
  end

  def next
    RecruitmentCycle.find_by(year: year.to_i + 1)
  end

  def next?
    RecruitmentCycle.next_recruitment_cycle == self
  end

  def current?
    RecruitmentCycle.current_recruitment_cycle == self
  end

  def current_and_open?
    current? && FeatureService.enabled?("rollover.has_current_cycle_started?")
  end

  def to_s
    following_year = Date.new(year.to_i, 1, 1) + 1.year
    "#{year}/#{following_year.strftime('%y')}"
  end

  def title
    if current_and_open?
      "Current cycle (#{year_range})"
    elsif current?
      "New cycle (#{year_range})"
    elsif next?
      "Next cycle (#{year_range})"
    else
      year_range
    end
  end

  def status
    @status ||= if current?
                  :current
                elsif application_start_date.future?
                  :upcoming
                else
                  :inactive
                end
  end

  def upcoming?
    status == :upcoming
  end

  def rollover_awaiting_start?
    providers.count.zero?
  end

  def year_range
    "#{year.to_i - 1} to #{year}"
  end

  def rollover_period_2026?
    year.to_i == 2026 && Time.zone.now < rollover_end
  end

  def rollover_end
    application_start_date + 1.month
  end

  # TODO: remove once the 2022 rollover is complete
  def after_2021?
    year.to_i >= 2022
  end

  def after_2025?
    year.to_i > 2025
  end
end
