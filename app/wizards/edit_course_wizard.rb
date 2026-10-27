# frozen_string_literal: true

# Edits a saved course's funding type or visa sponsorship.
#
# It draws the course questions of CourseWizard (the course_details flow) and
# starts from the course's answers. Like a change from check answers, it asks
# only the questions that need an answer from the one the edit opened on. It
# ends on the course page, after a confirm page for a published course with
# changes, since they go live when saved.
#
# The edit is kept in the wizard metadata (:edit): the course, the step it
# opened on, and the page to return to. The step it opened on is never read
# from a URL param, which a user could change to open a question they may not
# edit (the funding type of a published course, say).
class EditCourseWizard < CourseWizard
  VISA_STEPS = %i[
    visa_sponsorship
    skilled_worker_visa
    visa_sponsorship_application_deadline_required
    visa_sponsorship_application_deadline_at
  ].freeze

  EDITABLE_STEPS = [:funding_type, *VISA_STEPS].freeze

  # The saved course
  attr_accessor :record

  # The edit an edit link opens: :visa for the visa questions, otherwise the
  # funding type, which comes with the visa questions a change brings
  def self.unit_for(entry)
    entry = entry.to_s.to_sym
    entry == :visa || VISA_STEPS.include?(entry) ? :visa : :funding_type
  end

  def steps_processor
    DfE::Wizard::StepsProcessor::Graph.draw(self, predicate_caller: state_store) do |graph|
      graph.flow :course_details
      graph.add_node :confirm_changes, Steps::ConfirmChanges
      graph.add_node :course_page, DfE::Wizard::Core::Redirect
      graph.before_next_step :next_step_in_edit
      graph.before_previous_step :previous_step_in_edit
    end
  end

  # Edit questions save to the state store; the edit is saved to the course
  # when it reaches the course page (see Operations::UpdateCourse)
  def steps_operator
    DfE::Wizard::StepsOperator::Builder.draw(wizard: self, callable: state_store) { |_builder| nil }
  end

  def route_strategy
    DfE::Wizard::RouteStrategy::DynamicRoutes.new(
      state_store:,
      path_builder: lambda { |step_id, _state_store, helpers, options|
        next caller_url if step_id == :course_page

        helpers.edit_wizard_publish_provider_recruitment_cycle_course_path(
          provider_code:,
          recruitment_cycle_year:,
          code: record.course_code,
          state_key:,
          step: step_id,
          **options,
        )
      },
    )
  end

  # Seeds the edit from the course and returns the step it opens on: the
  # question named, or the first visa question on the path for the visa edit.
  # Returns nil when the course does not ask it (a TDA course has no funding
  # type question, a further education course no visa questions).
  def start(entry:, caller:)
    state_store.write(Mapper.new.to_answers(record))
    step_id = opening_step(entry.to_s.to_sym)

    unless step_id
      clear_state
      return
    end

    set_metadata(:edit, { course_id: record.id, entry: step_id, caller: })
    @edit = nil
    step_id
  end

  # The edit was started for this course, has not been saved or expired, and
  # still has a question to ask
  def active?
    edit[:course_id] == record.id && EDITABLE_STEPS.include?(entry) && question_steps.any?
  end

  # The step the edit opened on, which a change from check answers reads
  # from return_to_review
  def entry
    edit[:entry]&.to_sym
  end

  alias_method :return_to_review, :entry

  def caller_url
    edit[:caller]
  end

  def unit
    self.class.unit_for(entry)
  end

  # The questions the edit can ask: the one it opened on, and the editable
  # questions after it on the path
  def question_steps
    path = flow_path(check_answers_step)
    return [] unless path.include?(entry)

    path.drop(path.index(entry)) & EDITABLE_STEPS
  end

  # Steps the user can open: the edit's questions, and the confirm page once
  # each question has an answer and the course would change
  def accessible?(step_id)
    return question_steps.include?(step_id) unless step_id == :confirm_changes

    confirm_due? && question_steps.all? { |question| valid?(question) }
  end

  # The answers of the edit's questions on the path
  def answers
    (flow_path(check_answers_step) & EDITABLE_STEPS)
      .flat_map { |step_id| find_step(step_id).attribute_names.map(&:to_sym) }
      .index_with { |attribute| state_store.public_send(attribute) }
  end

  # The answers would change the course
  def changes?
    course = Course.find(record.id)
    course.assign_attributes(Mapper.new.to_attributes(answers, course))
    course.changed?
  end

private

  def edit
    @edit ||= get_metadata(:edit, default: {})
  end

  def opening_step(entry)
    path = flow_path(check_answers_step)
    return entry if EDITABLE_STEPS.include?(entry) && path.include?(entry)

    (path & VISA_STEPS).first if self.class.unit_for(entry) == :visa
  end

  def confirm_due?
    record.is_published? && changes?
  end

  def next_step_in_edit
    return :course_page if current_step_name == :confirm_changes

    next_step_in_review(finish: confirm_due? ? :confirm_changes : :course_page, only: EDITABLE_STEPS)
  end

  def previous_step_in_edit
    return (question_steps & review_shown).last || entry if current_step_name == :confirm_changes

    previous_step_in_review(entry, finish: :course_page)
  end
end
