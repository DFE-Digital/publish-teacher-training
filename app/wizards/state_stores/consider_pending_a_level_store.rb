# frozen_string_literal: true

module StateStores
  class ConsiderPendingALevelStore
    include DfE::Wizard::StateStore
    delegate :course, to: :wizard

    def save
      course.update!(accept_pending_a_level: current_step.pending_a_level == "yes")
    end
  end
end
