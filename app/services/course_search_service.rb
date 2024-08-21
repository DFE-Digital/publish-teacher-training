# frozen_string_literal: true

class CourseSearchService
  include ServicePattern
  attr_reader :sort, :filter, :course_scope

  FILTERS = [
    CourseFilters::SalaryFilter,
    CourseFilters::QualificationsFilter,
    CourseFilters::ApplicationsOpenFilter,
    CourseFilters::FindableFilter,
    CourseFilters::StudyModesFilter,
    CourseFilters::SubjectsFilter,
    CourseFilters::ProviderNameFilter,
    CourseFilters::SendFilter,
    CourseFilters::LocationsFilter,
    CourseFilters::FundingTypesFilter,
    CourseFilters::DegreeGradesFilter,
    CourseFilters::UpdateSinceFilter,
    CourseFilters::VisaSponsorshipFilter,
    CourseFilters::EngineersTeachPhysicsFilter
  ].freeze

  def initialize(
    filter:,
    sort: nil,
    course_scope: Course,
    course_type_answer_determiner: Find::CourseTypeAnswerDeterminer
  )
    @filter = filter || {}
    @course_scope = course_scope
    @sort = sort
    @course_type_answer_determiner = course_type_answer_determiner.new(
      university_degree_status: @filter['university_degree_status'],
      age_group: @filter['age_group'],
      visa_status: @filter['visa_status']
    )
  end

  def call
    scope = course_scope
    scope = filter_courses(scope)
    scope = with_course_type(scope)

    # The 'where' scope will remove duplicates
    # An outer query is required in the event the provider name is present.
    # This prevents 'PG::InvalidColumnReference: ERROR: for SELECT DISTINCT, ORDER BY expressions must appear in select list'
    scope = Course.includes(
      :enrichments,
      :financial_incentives,
      course_subjects: [:subject],
      site_statuses: [:site],
      provider: %i[recruitment_cycle ucas_preferences]
    ).where(id: scope.select(:id))

    ordering_strategy.order(scope)
  end

  def ordering_strategy
    raise NotImplementedError, 'Subclasses must implement the #ordering_strategy method'
  end

  def with_course_type(scope)
    raise NotImplementedError, 'Subclasses must implement the #with_course_type method'
  end

  def filter_courses(scope)
    all_filters = FILTERS.map { |filter_class| filter_class.new(self) }
    applicable_filters = all_filters.select(&:applicable_filter?)

    applicable_filters.inject(scope) do |current_scope, filter|
      filter.call(current_scope)
    end
  end

  def course_type
    return :undergraduate if @course_type_answer_determiner.show_undergraduate_courses?

    :postgraduate
  end

  private_class_method :new
end
