# == Schema Information
#
# Table name: recruitment_cycle
#
#  id                     :bigint           not null, primary key
#  year                   :string
#  application_start_date :date
#  application_end_date   :date
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class RecruitmentCycle < ApplicationRecord
  has_many :providers
  # Because this is through a has_many, these associations can't be updated,
  # which is a good thing since we don't have a good way to "move" a course or
  # a site to a new recruitment_cycle
  has_many :courses, through: :providers
  has_many :sites, through: :providers

  validates :year, presence: true

  def self.current_recruitment_cycle
    all.order(:year).first
  end

  def self.next_recruitment_cycle
    current_recruitment_cycle.next
  end

  def next
    RecruitmentCycle.find_by(year: year.to_i + 1)
  end

  def current?
    RecruitmentCycle.current_recruitment_cycle == self
  end

  def to_s
    following_year = Date.new(year.to_i, 1, 1) + 1.year
    "#{year}/#{following_year.strftime('%y')}"
  end
end
