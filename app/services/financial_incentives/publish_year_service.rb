# frozen_string_literal: true

module FinancialIncentives
  # Makes one complete financial incentive year visible for active subjects.
  #
  # The public Find/API read paths use each subject's displayed incentive. This
  # service therefore flips visibility for the whole selected year in one
  # transaction: existing displayed records for active subjects are hidden, then
  # the selected year's records are marked displayed. Discontinued subjects are
  # intentionally outside the default scope.
  class PublishYearService
    include ServicePattern

    # Raised when publishing would leave at least one active subject without a
    # visible incentive for the selected year.
    class IncompleteYearError < StandardError
      # @return [Array<Subject>] active subjects missing a target-year financial incentive
      attr_reader :missing_subjects

      # @param year [Integer] target financial incentive year
      # @param missing_subjects [Array<Subject>] active subjects missing records for the target year
      def initialize(year:, missing_subjects:)
        @missing_subjects = missing_subjects
        super("Financial incentives for #{year} are missing for #{missing_subjects.size} subjects")
      end
    end

    # @param year [Integer, String] target financial incentive year to publish
    # @param subject_scope [ActiveRecord::Relation<Subject>] subjects whose displayed incentives should be switched
    # @param financial_incentive [Class] injectable FinancialIncentive model for persistence
    def initialize(year:, subject_scope: Subject.active, financial_incentive: FinancialIncentive)
      @year = year.to_i
      @subject_scope = subject_scope
      @financial_incentive = financial_incentive
    end

    # @return [void]
    # @raise [IncompleteYearError] when any active subject is missing a target-year record
    def call
      missing_subjects = subjects_missing_incentives.to_a
      raise IncompleteYearError.new(year: @year, missing_subjects:) if missing_subjects.any?

      current_time = Time.current

      @financial_incentive.transaction do
        @financial_incentive.where(subject_id: active_subject_ids, displayed: true).update_all(displayed: false, updated_at: current_time)
        target_year_incentives.update_all(displayed: true, updated_at: current_time)
      end
    end

  private

    def subjects_missing_incentives
      @subject_scope.where.not(id: target_year_incentives.select(:subject_id)).order(:subject_name)
    end

    def target_year_incentives
      @financial_incentive.for_year(@year).where(subject_id: active_subject_ids)
    end

    def active_subject_ids
      @active_subject_ids ||= @subject_scope.select(:id)
    end
  end
end
