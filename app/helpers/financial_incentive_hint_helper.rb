# frozen_string_literal: true

module FinancialIncentiveHintHelper
  def bursary_value
    return if course.salary? || course.apprenticeship?
    return unless funding_view.bursary_and_scholarship_flag_active_or_preview?
    return if search_by_visa_sponsorship? && !funding_view.non_uk_funding_available?

    funding_view.hint_text
  end

private

  def funding_view
    @funding_view ||= CourseFunding::View.new(CourseFunding.new(course))
  end

  # Components that support visa sponsorship filtering can override this.
  def search_by_visa_sponsorship?
    respond_to?(:visa_sponsorship, true) && visa_sponsorship.present?
  end
end
