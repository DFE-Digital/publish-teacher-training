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
    recommendation_for_qts: "",
    professional: "PF",
    postgraduate: "PG",
    professional_postgraduate: "BO",
  }

  enum program_type: {
    higher_education_programme: "HE",
    school_direct_training_programme: "SD",
    school_direct_salaried_training_programme: "SS",
    scitt_programme: "SC",
    pg_teaching_apprenticeship: "TA",
  }

  enum study_mode: {
    full_time: "F",
    part_time: "P",
    full_time_or_part_time: "B",
  }

  enum age_range: {
    primary: "P",
    secondary: "S",
    middle_years: "M",
    # 'other' doesn't exist in the data yet but is reserved for courses that don't fit
    # the above categories
    other: "O",
  }

  belongs_to :provider
  belongs_to :accrediting_provider, class_name: 'Provider', optional: true
  has_and_belongs_to_many :subjects
  has_many :site_statuses
  has_many :sites, through: :site_statuses
  scope :pgde, -> {
    joins(:provider).
    joins("INNER JOIN pgde_course ON pgde_course.course_code = course.course_code AND pgde_course.provider_code = provider.provider_code")
  }

  # select * from course
  # inner join  course_subject
  #   on course.id = course_subject.course_id
  # inner join subject
  #   on  subject.id = course_subject.subject_id
  #   and  subject.subject_name = 'Further Education'
  # scope :further_education, -> {

  # }

  scope :changed_since, ->(datetime, from_course_id = 0) do
    if datetime.present?
      where("course.updated_at >= ? AND course.id > ?", datetime, from_course_id).order(:updated_at, :id)
    end
  end

  def recruitment_cycle
    "2019"
  end

  def findable?
    site_statuses.findable.any?
  end

  def open_for_applications?
    site_statuses.open_for_applications.any?
  end

  def has_vacancies?
    site_statuses.with_vacancies.any?
  end

  def qualifications
    is_fe = subjects.further_education.any?

    Qualifications.new(
      profpost_flag: profpost_flag,
      is_pgde: self.in?(Course.pgde),
      is_fe: subjects.further_education.any?,
    ).to_a
  end
end
