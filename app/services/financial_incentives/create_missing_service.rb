# frozen_string_literal: true

module FinancialIncentives
  # Repairs gaps in an existing financial incentive year.
  #
  # This is deliberately different from CreateYearService: missing records are
  # blank/default rather than copied from the displayed year. It is intended as
  # a support recovery action for partial years, not as the normal annual setup
  # path.
  class CreateMissingService
    include ServicePattern

    # @param year [Integer, String] target financial incentive year
    # @param subject [Subject, nil] optional single active subject to repair
    # @param subject_scope [ActiveRecord::Relation<Subject>] subjects to check for missing records
    # @param financial_incentive [Class] injectable FinancialIncentive model for persistence
    def initialize(year:, subject: nil, subject_scope: Subject.active, financial_incentive: FinancialIncentive)
      @year = year.to_i
      @subject = subject
      @subject_scope = subject_scope
      @financial_incentive = financial_incentive
    end

    # @return [Integer] number of blank financial incentive records created
    def call
      created_count = 0

      @financial_incentive.transaction do
        subjects_without_incentives.find_each do |subject|
          @financial_incentive.create!(
            FinancialIncentive::DEFAULT_ATTRIBUTES.merge(
              subject:,
              year: @year,
              displayed: false,
            ),
          )
          created_count += 1
        end
      end

      created_count
    end

  private

    def subjects_without_incentives
      subjects.where.not(id: @financial_incentive.for_year(@year).select(:subject_id))
    end

    def subjects
      return @subject_scope.where(id: @subject.id) if @subject.present?

      @subject_scope
    end
  end
end
