# frozen_string_literal: true

module ProviderSchools
  # Confirms a GIAS school can be added to a provider as a Provider::School.
  #
  # The Provider::School unique index covers gias_school_id per site_code, so
  # it would accept the same school twice under two codes; the duplicate check
  # lives here instead.
  class CheckForm
    include ActiveModel::Model

    attr_accessor :provider, :gias_school

    validate :school_not_already_added, :address_complete

  private

    def school_not_already_added
      errors.add(:gias_school, :already_added) if provider.schools.exists?(gias_school:)
    end

    def address_complete
      errors.add(:gias_school, :incomplete_address) unless gias_school.complete_address?
    end
  end
end
