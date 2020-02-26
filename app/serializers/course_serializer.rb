# == Schema Information
#
# Table name: course
#
#  accrediting_provider_code :text
#  age_range_in_years        :string
#  applications_open_from    :date
#  changed_at                :datetime         not null
#  course_code               :text
#  created_at                :datetime         not null
#  discarded_at              :datetime
#  english                   :integer
#  id                        :integer          not null, primary key
#  is_send                   :boolean          default("false")
#  level                     :string
#  maths                     :integer
#  modular                   :text
#  name                      :text
#  profpost_flag             :text
#  program_type              :text
#  provider_id               :integer          default("0"), not null
#  qualification             :integer          not null
#  science                   :integer
#  start_date                :datetime
#  study_mode                :text
#  updated_at                :datetime         not null
#
# Indexes
#
#  IX_course_provider_id_course_code          (provider_id,course_code) UNIQUE
#  index_course_on_accrediting_provider_code  (accrediting_provider_code)
#  index_course_on_changed_at                 (changed_at) UNIQUE
#  index_course_on_discarded_at               (discarded_at)
#

class CourseSerializer < ActiveModel::Serializer
  has_many :site_statuses, key: :campus_statuses
  has_many :subjects
  has_one :provider, serializer: CourseProviderSerializer
  has_one :accrediting_provider, serializer: CourseProviderSerializer

  attributes :course_code, :start_month, :name, :study_mode, :copy_form_required, :profpost_flag,
             :program_type, :modular, :english, :maths, :science, :recruitment_cycle,
             :start_month_string, :age_range, :created_at, :changed_at

  def profpost_flag
    object.profpost_flag_before_type_cast
  end

  def program_type
    object.program_type_before_type_cast
  end

  def study_mode
    object.study_mode_before_type_cast
  end

  def age_range
    if object.age_range_in_years == "7_to_14"
      "M"
    elsif object.level == "primary"
      "P"
    else
      "S"
    end
  end

  def maths
    object.maths_before_type_cast
  end

  def english
    object.english_before_type_cast
  end

  def science
    object.science_before_type_cast
  end

  def start_month
    object.start_date.iso8601 if object.start_date
  end

  def start_month_string
    object.start_date.strftime("%B") if object.start_date
  end

  def copy_form_required
    "Y" # we want to always create PDFs for applications coming in
  end

  def recruitment_cycle
    object.provider.recruitment_cycle.year
  end

  def created_at
    object.created_at.iso8601
  end

  def changed_at
    object.changed_at.iso8601
  end

  # Course now has a `is_send` attribute so we do not need to model `SEND` courses using the
  # Subject. However, API V1 is still expecting the Subject so we add it back in.
  def subjects
    subjects_array = object.syncable_subjects.to_a

    return subjects_array unless object.is_send?

    subjects_array << Subject.new(subject_code: "U3", subject_name: "Special Educational Needs")

    subjects_array
  end
end
