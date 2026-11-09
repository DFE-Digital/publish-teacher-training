# frozen_string_literal: true

module Support
  class AddUserWizard < BaseWizard
    step :details, Steps::Details
    commit_with Operations::CreateUser

    def build_step_path(helpers, step_id, **options)
      helpers.wizard_support_recruitment_cycle_users_path(
        context[:recruitment_cycle_year],
        state_key:,
        step: step_id,
        **options,
      )
    end

    def build_exit_path(helpers)
      helpers.support_recruitment_cycle_users_path(context[:recruitment_cycle_year])
    end
  end
end
