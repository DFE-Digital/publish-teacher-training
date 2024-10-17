# frozen_string_literal: true

module Publish
  # Change the accredited provider of a training_provider
  #
  # 1. Remove [1,2,3] Accredited Providers
  # 2. Add the target AccreditedProvider to the TrainingProvider
  # 3. Update all the courses that were accredited by old Accredited Providers to be accredited by the new Provider. Include courses with no Accredited Provider
  # 4. Remove the User Permissions of all users that had permissions on the removed accredited providers and have no permissions on any remaining Accredited Providers
  # 5. Add User Permissions for the Training Provider to any User associated with the new Accrediting Provider
  #
  class UpdateAccreditedProvider
    attr_reader :training_provider, :accredited_provider, :recruitment_cycle

    def initialize(training_provider_code:, recruitment_cycle_year:, to_provider_code:)
      @recruitment_cycle = RecruitmentCycle.find_by!(year: recruitment_cycle_year)
      @training_provider = Provider.find_by!(provider_code: training_provider_code, recruitment_cycle: @recruitment_cycle)
      @accredited_provider = Provider.find_by!(provider_code: to_provider_code, recruitment_cycle: @recruitment_cycle)
    end

    def call
      update_users && update_provider && update_courses
    end

    def update_provider
      training_provider.update_columns(accrediting_provider: 'not_an_accredited_provider',
                                       accrediting_provider_enrichments: new_accrediting_provider_enrichments)
    end

    def update_courses
      training_provider
        .courses.where(accredited_provider_code: nil)
        .or(training_provider.courses.where.not(accredited_provider_code: accredited_provider.provider_code))
        .update_all(accredited_provider_code: accredited_provider.provider_code)
    end

    # How do we identify the users that need their permissions removed?
    def update_users
      # providers_codes_to_be_removed = training_provider.accredited_providers.pluck(:id)
      new_provider_users = accredited_provider.users

      # Create permissions on the training provider for all the accredited provider users
      #
      records = new_provider_users.map { |u| { user_id: u.id, provider_id: training_provider.id } }
      UserPermission.create!(*records)

      # Remove permissions on the training provider for all users who do not
      # have permissions on the accredited provider
      users_to_remove_ids = training_provider.users.where.not(id: UserPermission.select(:user_id).where(provider_id: accredited_provider.id))
      training_provider.user_permissions.where(user_id: users_to_remove_ids).delete_all
    end

    private

    def new_accrediting_provider_enrichments
      existing_accrediting_provider_enrichments = training_provider.accrediting_provider_enrichments || []

      return existing_accrediting_provider_enrichments if new_accredited_provider_code_in_enrichments?(
        existing_accrediting_provider_enrichments
      )

      accredited_provider_enrichment = AccreditingProviderEnrichment.new(
        {
          UcasProviderCode: accredited_provider.provider_code,
          Description: ''
        }
      )

      existing_accrediting_provider_enrichments << accredited_provider_enrichment
    end

    def new_accredited_provider_code_in_enrichments?(accrediting_provider_enrichments)
      ucas_provider_code = accredited_provider.provider_code
      accrediting_provider_enrichments.map(&:UcasProviderCode).include?(ucas_provider_code)
    end
  end
end
