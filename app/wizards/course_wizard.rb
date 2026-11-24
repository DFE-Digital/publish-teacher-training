# frozen_string_literal: true

# Adds a course (the :create journey) or edits a saved one (the :edit
# journey). Both ask the course questions of the course_details flow, and each
# has its own ending.
#
# An edit is a change from check answers that ends on the course page: it
# starts from the course's answers, opens on the question its link names
# (return_to_review), asks only the questions of its unit that need an
# answer, and ends on the course page, after a confirm page for a published
# course with changes, since they go live when saved.
class CourseWizard
  include DfE::Wizard

  VISA_STEPS = %i[
    visa_sponsorship
    skilled_worker_visa
    visa_sponsorship_application_deadline_required
    visa_sponsorship_application_deadline_at
  ].freeze

  EDITABLE_STEPS = [:funding_type, *VISA_STEPS].freeze

  # The questions each edit can ask
  UNITS = { funding_type: EDITABLE_STEPS, visa: VISA_STEPS }.freeze

  TDA_REVIEW_DEFAULTS = %i[funding_type study_pattern skilled_worker_visa].freeze

  # The Subjects row on check answers also shows the languages and the design
  # and technology specialisms, which have no Change link of their own
  SUBJECTS_ROW_STEPS = %i[modern_languages_specialisms design_technology_specialisms].freeze

  attr_accessor :recruitment_cycle_year, :provider_code, :state_key

  # The edit: the saved course, and the unit edited (a key of UNITS)
  attr_accessor :record, :unit

  # The unit an edit link opens: :visa for the visa questions, otherwise the
  # funding type, which comes with the visa questions a change brings. An
  # unknown entry is the funding type, so it gets the funding type check.
  def self.unit_for(entry)
    entry = entry.to_s.to_sym
    entry == :visa || VISA_STEPS.include?(entry) ? :visa : :funding_type
  end

  delegate :accrediting_provider, to: :accreditation

  def steps_processor
    DfE::Wizard::StepsProcessor::Graph.draw(self, predicate_caller: state_store) do |graph|
      graph.flow :course_details

      graph.journey :create do
        graph.add_node :courses_index, DfE::Wizard::Core::Redirect
        graph.add_edge from: :check_answers, to: :courses_index
      end

      graph.journey :edit do
        graph.add_node :confirm_changes, Steps::ConfirmChanges
        graph.add_node :course_page, DfE::Wizard::Core::Redirect
        graph.before_next_step :next_step_in_edit
        graph.before_previous_step :previous_step_in_edit
      end
    end
  end

  # A change from check answers asks only the steps it affects, and the steps
  # its row shows, then goes back to check answers. Back retraces the steps it
  # showed. The gem tracks the change and clears the answers it takes off the
  # path. The edit's callbacks run first and end it on the course page.
  def review_navigation? = true

  # Creating saves the course from check answers. The edit saves its
  # questions to the state store, and the course when it reaches the course
  # page (see Operations::UpdateCourse).
  def steps_operator
    DfE::Wizard::StepsOperator::Builder.draw(wizard: self, callable: state_store) do |builder|
      if journey == :create
        builder.on_step(:check_answers, use: [DfE::Wizard::Operations::Validate, Operations::CreateCourse])
      end
    end
  end

  def route_strategy
    DfE::Wizard::RouteStrategy::DynamicRoutes.new(
      state_store:,
      path_builder: lambda { |step_id, _state_store, helpers, options|
        case step_id
        when :courses_index
          helpers.publish_provider_recruitment_cycle_courses_path(provider_code:, recruitment_cycle_year:, **options.except(:state_key))
        when :course_page
          helpers.details_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, record.course_code)
        else
          step_path(helpers, step_id, options)
        end
      },
    )
  end

  # The questions the edit can ask: its unit's questions on the path, from
  # the one it opened on
  def question_steps
    steps = flow_path(check_answers_step) & UNITS.fetch(unit)
    steps.include?(return_to_review) ? steps.drop(steps.index(return_to_review)) : steps
  end

  # The step an edit link opens: the question it names, or else the first
  # question of the visa edit. Nil when the course does not ask it (a TDA
  # course has no funding type question, a further education course no visa
  # questions).
  def opening_step(entry)
    entry = entry.to_s.to_sym
    return entry if question_steps.include?(entry)

    question_steps.first if unit == :visa
  end

  # Steps an edit URL can open: the edit's questions, from the one it opened
  # on, and the confirm page once each question has an answer and the course
  # would change
  def accessible?(step_id)
    return false unless question_steps.include?(return_to_review)
    return question_steps.include?(step_id) unless step_id == :confirm_changes

    confirm_due? && question_steps.all? { |question| valid?(question) }
  end

  def provider
    @provider ||= recruitment_cycle.providers.find_by!(provider_code:)
  end

  def recruitment_cycle
    @recruitment_cycle ||= RecruitmentCycle.find_by!(year: recruitment_cycle_year)
  end

  def skip_study_sites?
    provider.study_sites.none?
  end

  def accredited_provider_selection_required?
    accreditation.selection_required?
  end

  def accreditation
    @accreditation ||= Accreditation.new(
      provider:,
      selected_provider_code: state_store.accredited_provider_code,
    )
  end

  def final_step?
    current_step_name == :check_answers
  end

  # The steps on the path to check answers that have no valid answer, in path
  # order, each holding its validation errors. A step can be left unanswered
  # when an earlier answer changes the path, for example "yes" to visa
  # sponsorship after the deadline steps were skipped.
  def invalid_steps
    flow_path(check_answers_step).filter_map do |step_id|
      step(step_id) unless step_id == check_answers_step || valid?(step_id)
    end
  end

  def review_steps(draft:)
    steps = flow_steps
    steps = ensure_review_step(steps, :study_sites)
    steps = ensure_review_step(steps, :accredited_provider) if draft.accrediting_provider.present?
    return steps unless draft.tda?

    anchor_steps = {
      funding_type: :qualifications,
      study_pattern: :funding_type,
      skilled_worker_visa: :study_sites,
    }

    TDA_REVIEW_DEFAULTS.reduce(steps) do |ordered_steps, step_id|
      ensure_review_step_after(ordered_steps, step_id, after: anchor_steps.fetch(step_id))
    end
  end

  # Steps the row of the followed Change link shows besides its own step
  def review_asks_again(origin)
    origin == :secondary_subjects ? SUBJECTS_ROW_STEPS : []
  end

private

  def confirm_due?
    record.is_published? && Operations::UpdateCourse.new(wizard: self).changes?
  end

  def next_step_in_edit
    return :course_page if current_step_name == :confirm_changes

    next_step_in_review(finish: confirm_due? ? :confirm_changes : :course_page, only: question_steps)
  end

  def previous_step_in_edit
    return (question_steps & review_shown).last || return_to_review if current_step_name == :confirm_changes

    previous_step_in_review(return_to_review, finish: :course_page)
  end

  def step_path(helpers, step_id, options)
    route = { provider_code:, recruitment_cycle_year:, state_key:, step: step_id, **options }
    return helpers.publish_provider_recruitment_cycle_course_wizard_path(**route) unless journey == :edit

    helpers.edit_wizard_publish_provider_recruitment_cycle_course_path(code: record.course_code, unit:, **route)
  end

  # Flow: the questions about a course, up to check answers. Both journeys
  # draw it.
  def course_details(graph)
    graph.root :level

    graph.add_node :level, Steps::Level
    graph.add_node :primary_subjects, Steps::PrimarySubjects
    graph.add_node :secondary_subjects, Steps::SecondarySubjects

    # Secondary Subject specialist flows
    graph.add_node :design_technology_specialisms, Steps::DesignTechnologySpecialisms
    graph.add_node :physics_specialisms, Steps::PhysicsSpecialisms
    graph.add_node :modern_languages_specialisms, Steps::ModernLanguagesSpecialisms

    graph.add_node :age_range, Steps::AgeRange
    graph.add_node :qualifications, Steps::Qualifications
    graph.add_node :funding_type, Steps::FundingType
    graph.add_node :study_pattern, Steps::StudyPattern
    graph.add_node :schools, Steps::Schools
    graph.add_node :study_sites, Steps::StudySites, skip_when: -> { skip_study_sites? }
    graph.add_node :accredited_provider, Steps::AccreditedProvider
    graph.add_node :start_date, Steps::StartDate
    graph.add_node :visa_sponsorship, Steps::VisaSponsorship
    graph.add_node :skilled_worker_visa, Steps::SkilledWorkerVisa
    graph.add_node :visa_sponsorship_application_deadline_required, Steps::VisaSponsorshipApplicationDeadlineRequired
    graph.add_node :visa_sponsorship_application_deadline_at, Steps::VisaSponsorshipApplicationDeadlineAt

    graph.check_answers :check_answers, Steps::CheckAnswers

    graph.add_multiple_conditional_edges(
      from: :level,
      branches: [
        { when: :further_education_level?, then: :qualifications },
        { when: :primary_level?, then: :primary_subjects },
      ],
      default: :secondary_subjects,
    )

    graph.add_multiple_conditional_edges(
      from: :secondary_subjects,
      branches: [
        { when: :physics_specialisms?, then: :physics_specialisms },
        { when: :modern_languages_specialisms?, then: :modern_languages_specialisms },
        { when: :design_technology_specialisms?, then: :design_technology_specialisms },
      ],
      default: :age_range,
    )

    graph.add_multiple_conditional_edges(
      from: :physics_specialisms,
      branches: [
        { when: :modern_languages_specialisms?, then: :modern_languages_specialisms },
        { when: :design_technology_specialisms?, then: :design_technology_specialisms },
      ],
      default: :age_range,
    )

    graph.add_multiple_conditional_edges(
      from: :modern_languages_specialisms,
      branches: [
        { when: :design_technology_specialisms?, then: :design_technology_specialisms },
      ],
      default: :age_range,
    )

    graph.add_edge from: :design_technology_specialisms, to: :age_range

    graph.add_multiple_conditional_edges(
      from: :qualifications,
      branches: [
        { when: :undergraduate_degree_with_qts?, then: :schools },
      ],
      default: :funding_type,
    )

    graph.add_edge from: :primary_subjects, to: :age_range

    graph.add_edge from: :age_range, to: :qualifications

    graph.add_edge from: :funding_type, to: :study_pattern

    graph.add_edge from: :study_pattern, to: :schools

    graph.add_edge from: :schools, to: :study_sites

    graph.add_multiple_conditional_edges(
      from: :study_sites,
      branches: [
        # Further education does not require visa sponsorship in the
        # existing flow, so it goes straight to start date.
        { when: :further_education_level?, then: :start_date },
        # School-based providers with multiple accredited partners need
        # to choose who is accrediting the course.
        { when: -> { accredited_provider_selection_required? }, then: :accredited_provider },
        # TDA goes straight to start date when no accredited provider
        # selection is required.
        { when: :undergraduate_degree_with_qts?, then: :start_date },
        { when: :salary_based?, then: :skilled_worker_visa },
      ],
      default: :visa_sponsorship,
    )

    graph.add_multiple_conditional_edges(
      from: :accredited_provider,
      branches: [
        { when: :undergraduate_degree_with_qts?, then: :start_date },
        { when: :salary_based?, then: :skilled_worker_visa },
        { when: :fee_based?, then: :visa_sponsorship },
      ],
      default: :start_date,
    )

    graph.add_multiple_conditional_edges(
      from: :visa_sponsorship,
      branches: [
        { when: :visa_sponsorship_required?, then: :visa_sponsorship_application_deadline_required },
      ],
      default: :start_date,
    )

    graph.add_multiple_conditional_edges(
      from: :skilled_worker_visa,
      branches: [
        { when: :skilled_worker_visa_sponsorship_required?, then: :visa_sponsorship_application_deadline_required },
      ],
      default: :start_date,
    )

    graph.add_multiple_conditional_edges(
      from: :visa_sponsorship_application_deadline_required,
      branches: [
        { when: :deadline_for_application_visa_sponsorship_required?, then: :visa_sponsorship_application_deadline_at },
      ],
      default: :start_date,
    )

    graph.add_edge from: :visa_sponsorship_application_deadline_at, to: :start_date

    graph.add_edge from: :start_date, to: :check_answers
  end

  def ensure_review_step(steps, step_id)
    return steps if steps.any? { |step| step.step_id == step_id }

    steps + [step(step_id)]
  end

  def ensure_review_step_after(steps, step_id, after:)
    return steps if steps.any? { |current_step| current_step.step_id == step_id }

    review_step = step(step_id)
    insert_after_index = steps.index { |current_step| current_step.step_id == after }
    return steps + [review_step] if insert_after_index.nil?

    steps.dup.insert(insert_after_index + 1, review_step)
  end
end
