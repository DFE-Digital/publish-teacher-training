class NewCourseWizard
  extend Forwardable

  def_delegators :@course, :name=, :course_code=, :study_mode=, :age_range=,
                           :start_date=, :program_type=, :maths=, :english=,
                           :science=, :subjects=, :valid?
  attr_accessor :course

  def initialize(provider:, possible_ucas_subjects:, possible_sites:)
    @provider = provider
    @course = initialize_new_course

    @possible_ucas_subjects = possible_ucas_subjects
    @possible_sites = possible_sites
    @site_statuses = []
  end

  def qualification_options
    %w[qts pgce_with_qts pgde_with_qts pgce pgde]
  end

  def qualification_default
    :pgce_with_qts
  end

  def qualification=(new_value)
    @course.qualification = new_value
    @course.profpost_flag = @course.qts? ? :recommendation_for_qts : :postgraduate
  end

  def study_mode_options
    %w[full_time part_time full_time_or_part_time]
  end

  def study_mode_default
    :full_time
  end

  def age_range_options
    %w[primary secondary middle_years other]
  end

  def accredited_body_provider_code=(code)
    @course.accrediting_provider = code.present? ? Provider.find_by(provider_code: code) : @provider
  end

  def start_date_default
    Date.new(2019, 9, 1)
  end

  def program_type_options
    %w[
      higher_education_programme
      school_direct_training_programme
      school_direct_salaried_training_programme
      scitt_programme
      pg_teaching_apprenticeship
    ]
  end

  def entry_requirement_options
    Course::ENTRY_REQUIREMENT_OPTIONS.keys
  end

  def ucas_subject_options
    @possible_ucas_subjects
  end

  def site_options
    @possible_sites
  end

  def sites=(new_sites)
    @site_statuses = new_sites.map do |site|
      SiteStatus.new(site: site,
        status: :new_status,
        vac_status: vacancy_status,
        publish: :unpublished)
    end
  end

  def vacancy_status
    case @course.study_mode
    when "full_time"
      :full_time_vacancies
    when "part_time"
      :part_time_vacancies
    when "full_time_or_part_time"
      :both_full_time_and_part_time_vacancies
    else
      raise "Unexpected study mode #{@course.study_mode}"
    end
  end

  def applications_accepted_from=(new_value)
    @site_statuses.each { |site_status| site_status.applications_accepted_from = new_value }
  end

  def applications_accepted_from_default
    Date.today
  end

  def save!
    @course.save!
    @site_statuses.each { |site_status| site_status.course = course; site_status.save! }
  end

  def full_error_messages
    @course.errors&.full_messages
  end

private

  def initialize_new_course
    Course.new(
      provider: @provider,
      modular: '',
    )
  end
end
