# frozen_string_literal: true

class CourseWizard
  include DfE::Wizard

  attr_accessor :recruitment_cycle_year, :provider_code, :state_key

  delegate :accrediting_provider, to: :accreditation

  delegate :further_education_level?,
           :primary_level?,
           :undergraduate_degree_with_qts?,
           :visa_sponsorship_required?,
           :salary_based?,
           :fee_based?,
           :skilled_worker_visa_sponsorship_required?,
           :deadline_for_application_visa_sponsorship_required?,
           :design_technology_specialisms?,
           :physics_specialisms?,
           :modern_languages_specialisms?,
           to: :state_store

  def steps_processor
    DfE::Wizard::StepsProcessor::Graph.draw(self) do |graph|
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
      graph.add_node :study_sites, Steps::StudySites, skip_when: :skip_study_sites?
      graph.add_node :accredited_provider, Steps::AccreditedProvider
      graph.add_node :start_date, Steps::StartDate
      graph.add_node :visa_sponsorship, Steps::VisaSponsorship
      graph.add_node :skilled_worker_visa, Steps::SkilledWorkerVisa
      graph.add_node :visa_sponsorship_application_deadline_required, Steps::VisaSponsorshipApplicationDeadlineRequired
      graph.add_node :visa_sponsorship_application_deadline_at, Steps::VisaSponsorshipApplicationDeadlineAt

      graph.add_node :check_answers, Steps::CheckAnswers
      graph.add_node :courses_index, DfE::Wizard::Core::Redirect

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
          { when: :accredited_provider_selection_required?, then: :accredited_provider },
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
      graph.add_edge from: :check_answers, to: :courses_index

      graph.before_next_step(:handle_return_to_review)
      graph.before_previous_step(:handle_back_to_review)
    end
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

  def handle_return_to_review
    return if return_to_review_param.blank?

    handle_return_to_check_your_answers(:check_answers)
  end

  def handle_back_to_review
    return if return_to_review_param.blank?

    handle_back_in_check_your_answers(:check_answers, return_to_review_param)
  end

  def return_to_review_param
    # dfe-wizard's current pinned version of current_step_params only returns permitted step attributes,
    # so we need raw request params for return_to_review callback routing.
    @current_step_params&.[](:return_to_review) || @current_step_params&.[]("return_to_review")
  end
end
