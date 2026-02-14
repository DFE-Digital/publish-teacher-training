# frozen_string_literal: true

class SearchTitlePresenter
  def initialize(subjects:, location_name:, radius:, search_attributes:)
    @subjects = Array(subjects).compact
    @location_name = location_name
    @radius = radius
    @attrs = search_attributes || {}
  end

  def to_s
    return visa_title if no_subject_or_location? && visa_sponsorship?
    return apprenticeship_title if no_subject_or_location_or_visa? && apprenticeship_only?
    return salary_title if no_subject_or_location_or_visa? && salary_only?

    if @subjects.count == 1 && no_location?
      "#{@subjects.first} courses in England"
    elsif @subjects.count == 2 && no_location?
      "#{@subjects.first} and #{@subjects.second} courses in England"
    elsif @subjects.count >= 3 && no_location?
      "#{@subjects.count} subjects in England"
    elsif @subjects.empty? && location?
      "Courses within #{@radius} miles of #{@location_name}"
    elsif @subjects.count >= 3 && location?
      "Courses within #{@radius} miles of #{@location_name}"
    elsif @subjects.count == 1 && location?
      "#{@subjects.first} courses within #{@radius} miles of #{@location_name}"
    elsif @subjects.count == 2 && location?
      "#{@subjects.first} and #{@subjects.second} courses within #{@radius} miles of #{@location_name}"
    else
      fallback_title
    end
  end

  private

  def no_location? = @location_name.blank?
  def location? = @location_name.present?
  def no_subject_or_location? = @subjects.empty? && no_location?
  def visa_sponsorship? = @attrs["can_sponsor_visa"].present?

  def no_subject_or_location_or_visa?
    no_subject_or_location? && !visa_sponsorship?
  end

  def apprenticeship_only?
    funding = Array(@attrs["funding"])
    funding.include?("apprenticeship") && !funding.include?("salary") && !funding.include?("fee")
  end

  def salary_only?
    funding = Array(@attrs["funding"])
    funding.include?("salary") && !funding.include?("fee")
  end

  def visa_title = "Courses with visa sponsorship"
  def apprenticeship_title = "Apprenticeship courses in England"
  def salary_title = "Salaried courses in England"

  def fallback_title
    filter_count = active_filter_count
    if filter_count > 0
      "Courses across England (#{filter_count} filters applied)"
    else
      "Courses across England"
    end
  end

  def active_filter_count
    @attrs.count { |_, v| v.present? }
  end
end
