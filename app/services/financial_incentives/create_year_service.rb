# frozen_string_literal: true

module FinancialIncentives
  # Creates the initial hidden financial incentive records for a selected year.
  #
  # The support UI uses this when a year has no financial incentives yet. Each
  # active subject gets exactly one hidden target-year record. Values are copied
  # from that subject's currently displayed incentive, because the displayed
  # record is the candidate-facing source of truth. Subjects without a displayed
  # incentive get a blank/default record.
  class CreateYearService
    include ServicePattern

    class YearAlreadyExistsError < StandardError; end

    # @param year [Integer, String] target financial incentive year
    # @param subject_scope [ActiveRecord::Relation<Subject>] subjects to create records for; defaults to active subjects
    # @param financial_incentive [Class] injectable FinancialIncentive model for persistence
    def initialize(year:, subject_scope: Subject.active, financial_incentive: FinancialIncentive)
      @year = year.to_i
      @subject_scope = subject_scope
      @financial_incentive = financial_incentive
    end

    # @return [Integer] number of financial incentive records created
    # @raise [YearAlreadyExistsError] when any active subject already has a record for the target year
    def call
      raise YearAlreadyExistsError if records_for_year_exist?

      created_count = 0

      @financial_incentive.transaction do
        @subject_scope.includes(:financial_incentive).find_each do |subject|
          @financial_incentive.create!(
            attributes_from(subject.financial_incentive).merge(
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

    def records_for_year_exist?
      @financial_incentive.for_year(@year).where(subject_id: @subject_scope.select(:id)).exists?
    end

    def attributes_from(source_incentive)
      return FinancialIncentive::DEFAULT_ATTRIBUTES.dup if source_incentive.blank?

      FinancialIncentive::INCENTIVE_ATTRIBUTES.index_with do |attribute|
        source_incentive.public_send(attribute)
      end
    end
  end
end
