# == Schema Information
#
# Table name: course
#
#  id                        :integer          not null, primary key
#  age_range                 :text
#  course_code               :text
#  name                      :text
#  profpost_flag             :text
#  program_type              :text
#  qualification             :integer          not null
#  start_date                :datetime
#  study_mode                :text
#  accrediting_provider_id   :integer
#  provider_id               :integer          default(0), not null
#  modular                   :text
#  english                   :integer
#  maths                     :integer
#  science                   :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  changed_at                :datetime         not null
#  accrediting_provider_code :text
#  discarded_at              :datetime
#  age_range_in_years        :string
#  applications_open_from    :date
#  is_send                   :boolean          default(FALSE)
#  level                     :integer          default(0)
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
    object.age_range_before_type_cast
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
    return object.subjects unless object.is_send?

    subjects_array = object.subjects.to_a
    subjects_array << Subject.new(subject_code: 'U3', subject_name: 'Special Educational Needs')

    subjects_array
  end
end
