# frozen_string_literal: true

class CourseWizard
  # An edit of a saved course through the course wizard.
  #
  # The edit starts from the course's answers (see Mapper) under a new
  # state_key, and asks the questions of one unit: funding type (with the
  # visa questions a funding change brings), or visa sponsorship. Like a
  # change from check answers, it shows a question only when it needs an
  # answer. It ends on the course page, after a confirm page for a published
  # course, whose changes go live when saved.
  #
  # What the edit started from (the course, its updated_at, the seeded
  # answers, the page to return to) is kept in the wizard metadata under
  # :edit, next to the answers.
  class Edit
    VISA_STEPS = %i[
      visa_sponsorship
      skilled_worker_visa
      visa_sponsorship_application_deadline_required
      visa_sponsorship_application_deadline_at
    ].freeze

    UNITS = {
      funding_type: [:funding_type, *VISA_STEPS],
      visa: VISA_STEPS,
    }.freeze

    # The unit an edit link opens: a unit id, or the id of a visa step to
    # open the visa unit on
    def self.unit_for(entry)
      entry = entry.to_s.to_sym
      return entry if UNITS.key?(entry)

      :visa if VISA_STEPS.include?(entry)
    end

    def initialize(wizard)
      @wizard = wizard
    end

    # Seeds the edit and returns the step it opens on, or nil when the course
    # does not ask that question (a TDA course has no funding type question,
    # a further education course no visa questions)
    def start(entry:, caller:)
      unit = self.class.unit_for(entry) || raise(ArgumentError, "Unknown edit #{entry}")
      seed = Mapper.new.to_answers(course)
      wizard.state_store.write(seed)

      steps = path & UNITS.fetch(unit)
      entry_step = steps.include?(entry.to_sym) ? entry.to_sym : steps.first
      unless entry_step
        wizard.clear_state
        return
      end

      wizard.set_metadata(
        :edit,
        {
          course_id: course.id,
          updated_at: timestamp(course),
          caller:,
          unit:,
          entry: entry_step,
          seed: seed.transform_values { |value| normalise(value) },
        },
      )
      entry_step
    end

    # The edit was started for this course, has not been saved or expired, and
    # still has a question to ask
    def active?
      metadata[:course_id] == course.id && UNITS.key?(unit) && entry.present? && question_steps.any?
    end

    def unit
      metadata[:unit]&.to_sym
    end

    def entry
      metadata[:entry]&.to_sym
    end

    def caller_url
      metadata[:caller]
    end

    # The questions the edit can ask: its unit's questions on the path, from
    # the one it opened on
    def question_steps
      steps = path & UNITS.fetch(unit)
      steps.drop(steps.index(entry) || 0)
    end

    # Steps the user can open in this edit. The confirm page opens once each
    # question has an answer and there is a change to confirm.
    def accessible?(step_id)
      return question_steps.include?(step_id) unless step_id == :confirm_changes

      finish_step == :confirm_changes && question_steps.all? { |step| wizard.valid?(step) }
    end

    # Where the edit goes once its questions are answered: the confirm page
    # for a change to a published course, otherwise the course page (and the
    # edit is saved)
    def finish_step
      course.is_published? && diff.any? ? :confirm_changes : :courses_index
    end

    def next_step
      return :courses_index if wizard.current_step_name == :confirm_changes

      wizard.next_step_in_review(finish: finish_step, only: question_steps)
    end

    def previous_step
      return (question_steps & wizard.review_shown).last || entry if wizard.current_step_name == :confirm_changes

      wizard.previous_step_in_review(entry, finish: :courses_index)
    end

    # The answers on the path that differ from the seed. Answers off the path
    # are left out: the funding and visa rules reset what they held.
    def diff
      seed = metadata.fetch(:seed, {})

      (path - [wizard.check_answers_step]).flat_map { |step_id| attribute_names(step_id) }.uniq.each_with_object({}) do |attribute, changes|
        value = wizard.state_store.public_send(attribute)
        changes[attribute] = value unless comparable(attribute, value) == comparable(attribute, seed[attribute])
      end
    end

    # Someone else saved the course after the edit started
    def stale?
      metadata[:updated_at] != timestamp(course)
    end

    # Saves the edit, unless nothing changed or the course is stale, and
    # ends it. Returns { status:, errors: }.
    def commit!
      changes = diff
      result = if changes.empty?
                 { status: :unchanged, errors: [] }
               elsif stale?
                 { status: :stale, errors: [] }
               else
                 saved = Operations::UpdateCourse.new(course:, diff: changes).execute
                 saved[:success] ? { status: :committed, errors: [] } : { status: :failed, errors: saved[:errors] }
               end

      wizard.clear_state
      result
    end

  private

    attr_reader :wizard

    def course
      wizard.record
    end

    def metadata
      @metadata ||= wizard.get_metadata(:edit, default: {})
    end

    def path
      wizard.flow_path(wizard.check_answers_step)
    end

    def attribute_names(step_id)
      wizard.find_step(step_id).attribute_names.map(&:to_sym)
    end

    def timestamp(record)
      record.updated_at.utc.iso8601(6)
    end

    # Answers as they are kept: JSON values, so a value read back from the
    # cache compares equal to the one written
    def normalise(value)
      JSON.parse([value].to_json).first
    end

    # Answers as they are compared: a date as a date, so 09 and 9 are the
    # same month
    def comparable(attribute, value)
      return Draft::DateParts.parse(normalise(value))&.to_date if attribute == :visa_sponsorship_application_deadline_at

      normalise(value)
    end
  end
end
