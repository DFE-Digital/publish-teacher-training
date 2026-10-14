# frozen_string_literal: true

class CourseWizard
  include DfE::Wizard

  TDA_REVIEW_DEFAULTS = %i[funding_type study_pattern skilled_worker_visa].freeze

  attr_accessor :recruitment_cycle_year, :provider_code, :state_key

  delegate :accrediting_provider, to: :accreditation

  delegate :design_technology_specialisms?,
           :physics_specialisms?,
           :modern_languages_specialisms?,
           to: :state_store

  def steps_processor
    DfE::Wizard::StepsProcessor::Graph.draw(self, predicate_caller: state_store) do |graph|
      graph.root :level

      graph.add_node :level, Steps::Level
      graph.add_node :primary_subjects, Steps::PrimarySubjects
      graph.add_node :secondary_subjects, Steps::SecondarySubjects

      # Secondary Subject specialist flows
      graph.add_node :design_technology_specialisms, Steps::DesignTechnologySpecialisms,
                     depends_on: %i[secondary_master_subject_id subordinate_subject_id]
      graph.add_node :physics_specialisms, Steps::PhysicsSpecialisms,
                     depends_on: %i[secondary_master_subject_id subordinate_subject_id]
      graph.add_node :modern_languages_specialisms, Steps::ModernLanguagesSpecialisms,
                     depends_on: %i[secondary_master_subject_id subordinate_subject_id]

      graph.add_node :age_range, Steps::AgeRange
      graph.add_node :qualifications, Steps::Qualifications
      graph.add_node :funding_type, Steps::FundingType, depends_on: %i[qualification]
      graph.add_node :study_pattern, Steps::StudyPattern, depends_on: %i[qualification]
      graph.add_node :schools, Steps::Schools
      graph.add_node :study_sites, Steps::StudySites, skip_when: -> { skip_study_sites? }
      graph.add_node :accredited_provider, Steps::AccreditedProvider
      graph.add_node :start_date, Steps::StartDate
      graph.add_sub_wizard :visa, VisaSubWizard, exit_to: :start_date, depends_on: %i[qualification funding_type]

      graph.add_node :check_answers, Steps::CheckAnswers
      graph.add_node :courses_index, DfE::Wizard::Core::Redirect
      graph.check_answers :check_answers

      # Edits of a published course end here, before they are saved
      graph.add_node :confirm_changes, Steps::ConfirmChanges, skip_when: -> { skip_confirm_changes? }
      graph.edit_review :confirm_changes

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

      graph.add_edge from: :start_date, to: :check_answers
      graph.add_edge from: :check_answers, to: :courses_index
    end
  end

  def steps_operator
    DfE::Wizard::StepsOperator::Builder.draw(wizard: self, callable: state_store) do |builder|
      builder.on_step(:check_answers, use: [Operations::CreateCourse])
      builder.on_commit(use: [Operations::UpdateCourse])
    end
  end

  # Seeds an edit of a saved course (built with record:)
  def mapper
    Mapper.new
  end

  def route_strategy
    DfE::Wizard::RouteStrategy::DynamicRoutes.new(
      state_store:,
      path_builder: lambda { |step_id, _state_store, helpers, options|
        case step_id
        when :courses_index
          helpers.publish_provider_recruitment_cycle_courses_path(
            provider_code:,
            recruitment_cycle_year:,
            **options.except(:state_key),
          )
        else
          next edit_step_path(helpers, step_id, options) if editing?

          helpers.publish_provider_recruitment_cycle_course_wizard_path(
            provider_code:,
            recruitment_cycle_year:,
            state_key:,
            step: step_id,
            **options,
          )
        end
      },
    )
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

  # Only an edit of a published course asks the user to confirm, because
  # its changes go live when they are saved
  def skip_confirm_changes?
    !record&.is_published?
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

  def clear_stale_specialism_answers
    return unless current_step_name == :secondary_subjects

    reset_attributes = {}
    reset_attributes[:campaign_name] = nil unless physics_specialisms?
    reset_attributes[:language_ids] = nil unless modern_languages_specialisms?
    reset_attributes[:design_technology_ids] = nil unless design_technology_specialisms?
    return if reset_attributes.empty?

    state_store.write(**reset_attributes)
    nil
  end

private

  def edit_step_path(helpers, step_id, options)
    helpers.edit_wizard_publish_provider_recruitment_cycle_course_path(
      provider_code:,
      recruitment_cycle_year:,
      code: record.course_code,
      state_key:,
      step: step_id,
      **options,
    )
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
