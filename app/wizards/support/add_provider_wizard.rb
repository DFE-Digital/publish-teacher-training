# frozen_string_literal: true

module Support
  class AddProviderWizard < BaseWizard
    step :provider_details, Steps::ProviderDetails
    step :contact_details, Steps::ContactDetails
    commit_with Operations::CreateProvider

    # Set by Operations::CreateProvider so the controller can link to it.
    attr_accessor :created_provider

    def recruitment_cycle
      @recruitment_cycle ||= RecruitmentCycle.find_by!(year: context[:recruitment_cycle_year])
    end

    def build_step_path(helpers, step_id, **options)
      helpers.wizard_support_recruitment_cycle_providers_onboarding_path(
        context[:recruitment_cycle_year],
        state_key:,
        step: step_id,
        **options,
      )
    end

    def build_exit_path(helpers)
      helpers.support_recruitment_cycle_providers_path(context[:recruitment_cycle_year])
    end
  end
end
