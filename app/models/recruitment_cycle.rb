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
  has_many :courses
  has_many :sites

  validates :year, presence: true
end
