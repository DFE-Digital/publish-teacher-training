class RecruitmentCycle < ApplicationRecord
  has_many :providers, -> { kept }, inverse_of: false
  # Because this is through a has_many, these associations can't be updated,
  # which is a good thing since we don't have a good way to "move" a course or
  # a site to a new recruitment_cycle
  has_many :courses, through: :providers
  has_many :sites, through: :providers
  has_many :allocations

  validates :year, presence: true

  class << self
    def current_recruitment_cycle
      find_by(year: Settings.current_recruitment_cycle_year)
    end
    alias_method :current, :current_recruitment_cycle

    def next_recruitment_cycle
      current_recruitment_cycle.next
    end
    alias_method :next, :next_recruitment_cycle
  end

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

  def to_s
    following_year = Date.new(year.to_i, 1, 1) + 1.year
    "#{year}/#{following_year.strftime('%y')}"
  end
end
