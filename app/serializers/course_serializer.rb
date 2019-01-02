class CourseSerializer < ActiveModel::Serializer
  has_many :site_statuses, key: :campus_statuses
  has_many :subjects
  has_one :provider
  has_one :accrediting_provider

  attributes :course_code, :start_month, :name, :study_mode, :copy_form_required, :profpost_flag,
             :program_type, :modular, :english, :maths, :science, :qualification, :recruitment_cycle

  def start_month
    object.start_date.iso8601 if object.start_date
  end

  def copy_form_required
    "Y" # we want to always create PDFs for applications coming in
  end

  # TODO: make recruitment cycle dynamic
  def recruitment_cycle
    "2019"
  end
end
