# frozen_string_literal: true

class CourseWizard
  # The visa questions: student visa or skilled worker visa, then the
  # application deadline. Drawn into CourseWizard's graph with
  # add_sub_wizard. Its open exits go to exit_to (start_date).
  class VisaSubWizard
    extend DfE::Wizard::SubWizard

    uses :visa_sponsorship_required?,
         :skilled_worker_visa_sponsorship_required?,
         :deadline_for_application_visa_sponsorship_required?,
         :provider,
         :recruitment_cycle,
         :accrediting_provider

    def self.draw(graph)
      graph.add_node :visa_sponsorship, Steps::VisaSponsorship
      graph.add_node :skilled_worker_visa, Steps::SkilledWorkerVisa
      graph.add_node :visa_sponsorship_application_deadline_required, Steps::VisaSponsorshipApplicationDeadlineRequired
      graph.add_node :visa_sponsorship_application_deadline_at, Steps::VisaSponsorshipApplicationDeadlineAt

      graph.add_multiple_conditional_edges(
        from: :visa_sponsorship,
        branches: [
          { when: :visa_sponsorship_required?, then: :visa_sponsorship_application_deadline_required },
        ],
      )

      graph.add_multiple_conditional_edges(
        from: :skilled_worker_visa,
        branches: [
          { when: :skilled_worker_visa_sponsorship_required?, then: :visa_sponsorship_application_deadline_required },
        ],
      )

      graph.add_multiple_conditional_edges(
        from: :visa_sponsorship_application_deadline_required,
        branches: [
          { when: :deadline_for_application_visa_sponsorship_required?, then: :visa_sponsorship_application_deadline_at },
        ],
      )
    end
  end
end
