# frozen_string_literal: true

module SearchTitlePresentable
  extend ActiveSupport::Concern

  def title
    SearchTitlePresenter.new(
      subjects: resolved_subject_names,
      location_name: location_display_name,
      radius: radius,
      search_attributes: search_attributes
    ).to_s
  end

  private

  def resolved_subject_names
    return [] if subjects.blank?

    Subject.where(subject_code: subjects).pluck(:subject_name)
  end

  def location_display_name
    search_attributes&.dig("location") ||
      search_attributes&.dig("formatted_address")
  end
end
