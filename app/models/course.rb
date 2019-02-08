# == Schema Information
#
# Table name: course
#
#  id                      :integer          not null, primary key
#  age_range               :text
#  course_code             :text
#  name                    :text
#  profpost_flag           :text
#  program_type            :text
#  qualification           :integer          not null
#  start_date              :datetime
#  study_mode              :text
#  accrediting_provider_id :integer
#  provider_id             :integer          default(0), not null
#  modular                 :text
#  english                 :integer
#  maths                   :integer
#  science                 :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class Course < ApplicationRecord
  enum profpost_flag: {
    "Recommendation for QTS" => "",
    "Professional" => "PF",
    "Postgraduate" => "PG",
    "Professional/Postgraduate" => "BO",
  }

  enum program_type: {
    "Higher education programme" => "HE",
    "School Direct training programme" => "SD",
    "School Direct (salaried) training programme" => "SS",
    "SCITT programme" => "SC",
    "PG Teaching Apprenticeship" => "TA",
  }

  enum study_mode: {
    "full time" => "F",
    "part time" => "P",
    "full time or part time" => "B",
  }

  enum age_range: {
    "primary" => "P",
    "secondary" => "S",
    "middle years" => "M",
    # 'other' doesn't exist in the data yet but is reserved for courses that don't fit
    # the above categories
    "other" => "O",
  }

  belongs_to :provider
  belongs_to :accrediting_provider, class_name: 'Provider', optional: true
  has_and_belongs_to_many :subjects
  has_many :site_statuses
  has_many :sites, through: :site_statuses

  scope :changed_since, ->(datetime, from_course_id = 0) do
    if datetime.present?
      where("course.updated_at >= ? AND course.id > ?", datetime, from_course_id).order(:updated_at, :id)
    end
  end

  def recruitment_cycle
    "2019"
  end
end
