class AllocationRequest
  COURSE_AIM_MAPPINGS = {
    # early_years_teacher_status: 'EYTS', # This system doesn't support this option
    qts: 'QTS Only',
    pgce_with_qts: 'QTS plus academic award',
    pgde_with_qts: 'QTS plus academic award',
  }.freeze

  ROUTE_MAPPINGS = {
    # The system doesn't support the following 3 options
    # EYITT Graduate employment-based
    # EYITT Graduate Entry
    # EYITT Undergraduate Entry
    pg_teaching_apprenticeship: "Post Graduate Teaching Apprenticeship",
    scitt_programme: "Provider-led",
    higher_education_programme: "Provider-led",
    school_direct_salaried_training_programme: "School Direct salaried",
    school_direct_training_programme: "School Direct tuition fee",
  }.freeze

  COURSE_LEVEL_MAPPINGS = {
    # undergraduate: "UG", # which isn't supported by this system
    postgraduate: "PG",
  }.freeze

  attr_reader :requesting_nctl_organisation, :partner_nctl_organisation,
              :subject, :route, :course_aim

  def initialize(requesting_nctl_organisation:, partner_nctl_organisation:,
                 subject:, route:, course_aim:)
    @requesting_nctl_organisation = requesting_nctl_organisation
    @partner_nctl_organisation = partner_nctl_organisation
    @subject = subject
    @route = route
    @course_aim = course_aim
  end

  def academic_year
    "2020/21"
  end

  def course_level
    :postgraduate
  end

  def to_a
    [
      academic_year,
      requesting_nctl_organisation.name,
      requesting_nctl_organisation.ukprn.to_s,
      partner_nctl_organisation&.name || '',
      partner_nctl_organisation&.ukprn.to_s || '',
      subject,
      ROUTE_MAPPINGS[route.to_sym],
      COURSE_AIM_MAPPINGS[course_aim.to_sym],
      COURSE_LEVEL_MAPPINGS[course_level.to_sym],
    ]
  end

  def eql?(other)
    self.to_a.eql?(other.to_a)
  end

  def hash
    to_a.hash
  end
end
