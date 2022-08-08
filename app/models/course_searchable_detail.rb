class CourseSearchableDetail < ApplicationRecord
  belongs_to :course, polymorphic: true

  self.primary_key = :id
  self.table_name = :course_searchable_details

  has_many :site_statuses, foreign_key: "course_id", inverse_of: :course
  has_many :sites,
    -> { distinct.merge(SiteStatus.where(status: %i[new_status running])) },
    through: :site_statuses

  scope :changed_since, lambda { |timestamp|
    if timestamp.present?
      changed_at_since(timestamp)
    else
      where.not(changed_at: nil)
    end.order(:changed_at, :id)
  }

  scope :changed_at_since, lambda { |timestamp|
    where("course_searchable_detail.changed_at > ?", timestamp)
  }

  scope :within, lambda { |range, origin:|
    joins(site_statuses: :site).merge(SiteStatus.where(status: :running)).merge(Site.within(range, origin:))
  }
  scope :with_recruitment_cycle, ->(year) { where(recruitment_cycle_year: year) }
  scope :findable, -> { joins(:site_statuses).merge(SiteStatus.findable) }
  scope :with_vacancies, -> { joins(:site_statuses).merge(SiteStatus.with_vacancies) }
  scope :with_salary, -> { where(is_salary: true) }
  scope :with_study_modes, lambda { |study_modes|
    where(is_full_time: study_modes.include?("full_time"), is_part_time: study_modes.include?("part_time"))
  }
  scope :with_subjects, lambda { |subject_codes|
    first_subject_code, *rest_subject_codes = subject_codes
    scope = where("? = ANY(course_searchable_detail.subject_codes)", first_subject_code)

    rest_subject_codes.each do |subject_code|
      scope = scope.or(where("? = ANY(course_searchable_detail.subject_codes)", subject_code))
    end

    scope
  }

  scope :with_qualifications, lambda { |qualifications|
    where(qualification: qualifications)
  }

  scope :with_accredited_bodies, lambda { |accredited_body_codes|
    where(accredited_body_code: accredited_body_codes)
  }

  scope :with_provider_name, lambda { |provider_name|
    where(provider_name:).or(where(accredited_body_provider_name: provider_name))
  }

  scope :with_send, lambda {
    where(is_send: true)
  }

  scope :with_funding_types, lambda { |funding_types|
    where(funding_type: funding_types)
  }

  scope :with_degree_grades, lambda { |degree_grades|
    where(degree_grade: degree_grades)
  }

  scope :provider_can_sponsor_visa, lambda {
    where(provider_can_sponsor_visa: true)
  }

  def readonly?
    true
  end
end
