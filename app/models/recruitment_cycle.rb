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
      find_by!(year: Find::CycleTimetable.current_year.to_s)
    end

    def current_recruitment_cycle
      find_by(year: Find::CycleTimetable.current_year.to_s)
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
    where(year: Find::CycleTimetable.current_year).or(upcoming_cycles_open_to_publish)
  end

  # Old cycle closes for providers the moment the new cycle starts
  scope :upcoming_cycles_open_to_publish, lambda {
    where(":now >= available_in_publish_from AND year > :current_year",
          now: Date.current,
          current_year: Find::CycleTimetable.current_year)
  }

  # All cycles available to support at a given time
  #
  # - Current cycle always available and returned
  # - Next/new cycle is available after 'available_for_support_users_from'
  # - Last cycle is available if it ended fewer than 30 days ago
  #
  scope :cycles_open_to_support, lambda {
    where(
      "year in (:current_and_next_year) AND :now >= available_for_support_users_from",
      current_and_next_year: [Find::CycleTimetable.current_year, Find::CycleTimetable.next_year],
      now: Date.current,
    ).or(
      where(year: Find::CycleTimetable.years_available_to_support),
    )
  }

  # Same as .cycles_open_to_support except it excludes the current cycle
  scope :rollover_cycles_open_to_support, lambda {
    where(
      "year = :next_year AND :now >= available_for_support_users_from",
      next_year: Find::CycleTimetable.next_year,
      now: Date.current,
    ).or(
      where(year: Find::CycleTimetable.years_available_to_support),
    )
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
    current? && Find::CycleTimetable.find_open?
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
    30.days.after(Find::CycleTimetable.find_opens(year))
  end

  # TODO: remove once the 2022 rollover is complete
  def after_2021?
    year.to_i >= 2022
  end

  def after_2025?
    year.to_i > 2025
  end
end
