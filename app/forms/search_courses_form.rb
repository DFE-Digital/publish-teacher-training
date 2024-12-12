# frozen_string_literal: true

class SearchCoursesForm < ApplicationForm
  include ActiveModel::Attributes

  attribute :can_sponsor_visa, :boolean
  attribute :send_courses, :boolean
  attribute :applications_open, :boolean
  attribute :study_types

  def search_params
    attributes.symbolize_keys.compact
  end
end
