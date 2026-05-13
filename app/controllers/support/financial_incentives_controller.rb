# frozen_string_literal: true

module Support
  class FinancialIncentivesController < ApplicationController
    before_action :set_year
    before_action :set_financial_incentive, only: %i[edit update]

    def index
      @subjects = subjects
      @financial_incentives_by_subject_id = financial_incentives_by_subject_id
      @missing_subjects = missing_subjects
      @financial_incentives = financial_incentives
      @year_options = year_options
    end

    def create_year
      redirect_to_index(success: t(".success", count: created_year_count, year:))
    rescue ::FinancialIncentives::CreateYearService::YearAlreadyExistsError
      redirect_to_index(warning: t(".already_exists", year:))
    end

    def create_missing
      redirect_to_index(create_missing_flash)
    end

    def create_blank
      redirect_to_index(create_blank_flash)
    end

    def confirm_publish
      @missing_subjects = missing_subjects

      return if @missing_subjects.none?

      redirect_to_index(warning: t(".missing", year:))
    end

    def publish
      ::FinancialIncentives::PublishYearService.call(year:)

      redirect_to_index(success: t(".success", year:))
    rescue ::FinancialIncentives::PublishYearService::IncompleteYearError => e
      redirect_to_index(warning: t(".missing", count: e.missing_subjects.size, year:))
    end

    def edit
      @year = financial_incentive.year
    end

    def update
      financial_incentive.assign_attributes(financial_incentive_params)
      @year = financial_incentive.year

      if financial_incentive.invalid?
        render :edit, status: :unprocessable_entity
      elsif visible_update_needs_confirmation?
        render :confirm_update
      else
        financial_incentive.save!
        redirect_to_index(success: t(".success", subject_name: financial_incentive.subject.subject_name))
      end
    end

  private

    attr_reader :financial_incentive, :year

    def subjects
      @subjects ||= Subject.active.order(:subject_name)
    end

    def financial_incentives_by_subject_id
      @financial_incentives_by_subject_id ||= FinancialIncentive
        .for_year(@year)
        .where(subject_id: subjects.select(:id))
        .includes(:subject)
        .index_by(&:subject_id)
    end

    def financial_incentives
      @financial_incentives ||= financial_incentives_by_subject_id.values
    end

    def missing_subjects
      @missing_subjects ||= subjects.reject { |subject| financial_incentives_by_subject_id.key?(subject.id) }
    end

    def set_year
      @year = selected_year
    end

    def set_financial_incentive
      @financial_incentive = FinancialIncentive.includes(:subject).find(params[:id])
    end

    def selected_year
      requested_year = parsed_requested_year
      return requested_year if allowed_years.include?(requested_year)

      FinancialIncentive.current_year
    end

    def parsed_requested_year
      return if params[:year].blank?
      return unless params[:year].to_s.match?(/\A\d+\z/)

      params[:year].to_i
    end

    def allowed_years
      @allowed_years ||= (
        FinancialIncentive.distinct.pluck(:year) +
        [FinancialIncentive.current_year, Find::CycleTimetable.next_year]
      ).compact.uniq
    end

    def year_options
      @year_options ||= allowed_years.sort.reverse
    end

    def created_year_count
      @created_year_count ||= ::FinancialIncentives::CreateYearService.call(year:)
    end

    def created_missing_count
      @created_missing_count ||= ::FinancialIncentives::CreateMissingService.call(year:)
    end

    def created_blank_count
      @created_blank_count ||= ::FinancialIncentives::CreateMissingService.call(year:, subject: blank_subject)
    end

    def blank_subject
      @blank_subject ||= Subject.active.find(params[:subject_id])
    end

    def create_missing_flash
      if created_missing_count.positive?
        return { success: t(".success", count: created_missing_count, year:) }
      end

      { warning: t(".none_missing", year:) }
    end

    def create_blank_flash
      if created_blank_count.positive?
        return { success: t(".success", subject_name: blank_subject.subject_name) }
      end

      {
        warning: t(
          ".already_exists",
          subject_name: blank_subject.subject_name,
          year:,
        ),
      }
    end

    def redirect_to_index(flash)
      redirect_to support_financial_incentives_path(year:), flash:
    end

    def visible_update_needs_confirmation?
      financial_incentive.displayed? && !confirmed_update?
    end

    def confirmed_update?
      params[:confirmed] == "true"
    end

    def financial_incentive_params
      params.expect(
        financial_incentive: FinancialIncentive::INCENTIVE_ATTRIBUTES,
      )
    end
  end
end
